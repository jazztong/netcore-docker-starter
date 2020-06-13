FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
EXPOSE 5000
ENV ASPNETCORE_URLS=http://*:5000
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "SimpleApi/SimpleApi.csproj"
WORKDIR "/src/."
RUN dotnet build "SimpleApi/SimpleApi.csproj" -c Release -o /app/build
FROM build AS publish
RUN dotnet publish "SimpleApi/SimpleApi.csproj" -c Release -o /app/publish
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
