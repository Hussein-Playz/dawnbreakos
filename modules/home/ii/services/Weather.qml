// pragma Singleton
// pragma ComponentBehavior: Bound
//
// import Quickshell
// import Quickshell.Io
// import QtQuick
// import QtPositioning
//
// import qs.modules.common
//
// Singleton {
//     id: root
//     // 10 minute
//     readonly property int fetchInterval: Config.options.bar.weather.fetchInterval * 60 * 1000
//     readonly property string city: Config.options.bar.weather.city
//     readonly property bool useUSCS: Config.options.bar.weather.useUSCS
//     property bool gpsActive: Config.options.bar.weather.enableGPS
//
//     onUseUSCSChanged: {
//         root.getData();
//     }
//     onCityChanged: {
//         root.getData();
//     }
//
//     property var location: ({
//         valid: false,
//         lat: 0,
//         lon: 0
//     })
//
//     property var data: ({
//         uv: 0,
//         humidity: 0,
//         sunrise: 0,
//         sunset: 0,
//         windDir: 0,
//         wCode: 0,
//         city: 0,
//         wind: 0,
//         precip: 0,
//         visib: 0,
//         press: 0,
//         temp: 0,
//         tempFeelsLike: 0,
//         lastRefresh: 0,
//     })
//
//     function refineData(data) {
//         let temp = {};
//         temp.uv = data?.current?.uvIndex || 0;
//         temp.humidity = (data?.current?.humidity || 0) + "%";
//         temp.sunrise = data?.astronomy?.sunrise || "0.0";
//         temp.sunset = data?.astronomy?.sunset || "0.0";
//         temp.windDir = data?.current?.winddir16Point || "N";
//         temp.wCode = data?.current?.weatherCode || "113";
//         temp.city = data?.location?.areaName[0]?.value || "City";
//         temp.temp = "";
//         temp.tempFeelsLike = "";
//         if (root.useUSCS) {
//             temp.wind = (data?.current?.windspeedMiles || 0) + " mph";
//             temp.precip = (data?.current?.precipInches || 0) + " in";
//             temp.visib = (data?.current?.visibilityMiles || 0) + " m";
//             temp.press = (data?.current?.pressureInches || 0) + " psi";
//             temp.temp += (data?.current?.temp_F || 0);
//             temp.tempFeelsLike += (data?.current?.FeelsLikeF || 0);
//             temp.temp += "°F";
//             temp.tempFeelsLike += "°F";
//         } else {
//             temp.wind = (data?.current?.windspeedKmph || 0) + " km/h";
//             temp.precip = (data?.current?.precipMM || 0) + " mm";
//             temp.visib = (data?.current?.visibility || 0) + " km";
//             temp.press = (data?.current?.pressure || 0) + " hPa";
//             temp.temp += (data?.current?.temp_C || 0);
//             temp.tempFeelsLike += (data?.current?.FeelsLikeC || 0);
//             temp.temp += "°C";
//             temp.tempFeelsLike += "°C";
//         }
//         temp.lastRefresh = DateTime.time + " • " + DateTime.date;
//         root.data = temp;
//     }
//
//     function getData() {
//         let command = "curl -s wttr.in";
//
//         if (root.gpsActive && root.location.valid) {
//             command += `/${root.location.lat},${root.location.long}`;
//         } else {
//             command += `/${formatCityName(root.city)}`;
//         }
//
//         // format as json
//         command += "?format=j1";
//         command += " | ";
//         // only take the current weather, location, asytronmy data
//         command += "jq '{current: .current_condition[0], location: .nearest_area[0], astronomy: .weather[0].astronomy[0]}'";
//         fetcher.command[2] = command;
//         fetcher.running = true;
//     }
//
//     function formatCityName(cityName) {
//         return cityName.trim().split(/\s+/).join('+');
//     }
//
//     Component.onCompleted: {
//         if (!root.gpsActive) return;
//         console.info("[WeatherService] Starting the GPS service.");
//         positionSource.start();
//     }
//
//     Process {
//         id: fetcher
//         command: ["bash", "-c", ""]
//         stdout: StdioCollector {
//             onStreamFinished: {
//                 if (text.length === 0)
//                     return;
//                 try {
//                     const parsedData = JSON.parse(text);
//                     root.refineData(parsedData);
//                     // console.info(`[ data: ${JSON.stringify(parsedData)}`);
//                 } catch (e) {
//                     console.error(`[WeatherService] ${e.message}`);
//                 }
//             }
//         }
//     }
//
//     PositionSource {
//         id: positionSource
//         updateInterval: root.fetchInterval
//
//         onPositionChanged: {
//             // update the location if the given location is valid
//             // if it fails getting the location, use the last valid location
//             if (position.latitudeValid && position.longitudeValid) {
//                 root.location.lat = position.coordinate.latitude;
//                 root.location.long = position.coordinate.longitude;
//                 root.location.valid = true;
//                 // console.info(`📍 Location: ${position.coordinate.latitude}, ${position.coordinate.longitude}`);
//                 root.getData();
//                 // if can't get initialized with valid location deactivate the GPS
//             } else {
//                 root.gpsActive = root.location.valid ? true : false;
//                 console.error("[WeatherService] Failed to get the GPS location.");
//             }
//         }
//
//         onValidityChanged: {
//             if (!positionSource.valid) {
//                 positionSource.stop();
//                 root.location.valid = false;
//                 root.gpsActive = false;
//                 Quickshell.execDetached(["notify-send", Translation.tr("Weather Service"), Translation.tr("Cannot find a GPS service. Using the fallback method instead."), "-a", "Shell"]);
//                 console.error("[WeatherService] Could not aquire a valid backend plugin.");
//             }
//         }
//     }
//
//     Timer {
//         running: !root.gpsActive
//         repeat: true
//         interval: root.fetchInterval
//         triggeredOnStart: !root.gpsActive
//         onTriggered: root.getData()
//     }
// }
pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string weatherLocation: ""

    property string weatherUnits: "metric"

    property bool useTwelveHourClock: false

    property string city: ""
    property string loc: ""

    property var cc: null

    property list<var> forecast: []
    property list<var> hourlyForecast: []


    property bool ipApiRequestPending: false
    property double ipApiBlockedUntil: 0

    property bool citiesLoaded: false
    property string pendingCoords: ""

    property double lastAutoLocationTime: 0

    readonly property var cachedCities: new Map()

    readonly property string icon: cc
    ? getWeatherIcon(cc.weatherCode)
    : "cloud_alert"

    readonly property string description: cc
    ? getWeatherCondition(cc.weatherCode)
    : "No weather"

    readonly property string temp:
    formatTemp(cc?.tempC)

        readonly property string feelsLike:
        formatTemp(cc?.feelsLikeC)

            readonly property int humidity:
            cc?.humidity ?? 0

            readonly property real windSpeed:
            cc?.windSpeed ?? 0

            readonly property string sunrise:
            cc
            ? Qt.formatDateTime(
                new Date(cc.sunrise),
                                useTwelveHourClock ? "h:mm AP" : "h:mm"
            )
            : "--:--"

            readonly property string sunset:
            cc
            ? Qt.formatDateTime(
                new Date(cc.sunset),
                                useTwelveHourClock ? "h:mm AP" : "h:mm"
            )
            : "--:--"


            function formatTemp(temp, compact = false): string {
                if (temp === undefined || temp === null || !Number.isFinite(Number(temp)))
                    return "--";

                let value = Number(temp);

                if (weatherUnits === "imperial" || weatherUnits === "us")
                    value = value * 9 / 5 + 32;

                value = Math.round(value);

                if (weatherUnits === "imperial" || weatherUnits === "us")
                    return `${value}°F`;

                return `${value}°C`;
            }

            function request(
                url: string,
                callback: var,
                errorCallback: var = null,
                headers: var = {}
            ): void {
                const xhr = new XMLHttpRequest();

                xhr.open("GET", url);

                for (const key in headers)
                    xhr.setRequestHeader(key, headers[key]);

                xhr.onreadystatechange = function() {
                    if (xhr.readyState !== XMLHttpRequest.DONE)
                        return;

                    if (xhr.status >= 200 && xhr.status < 300) {
                        callback(xhr.responseText, {
                            statusCode: xhr.status,
                            headers: {}
                        });
                    } else {
                        if (errorCallback)
                            errorCallback(
                                `HTTP ${xhr.status}: ${xhr.statusText}`,
                                {
                                    statusCode: xhr.status,
                                    headers: {}
                                }
                            );
                    }
                };

                xhr.onerror = function() {
                    if (errorCallback)
                        errorCallback(
                            "Network request failed",
                            {
                                statusCode: xhr.status,
                                headers: {}
                            }
                        );
                };

                xhr.send();
            }

            function reload(): void {
                const configLocation = weatherLocation.trim();
                if (configLocation) {
                    if (
                        configLocation.indexOf(",") !== -1 &&
                        !isNaN(parseFloat(configLocation.split(",")[0]))
                    ) {
                        loc = configLocation;
                        fetchCityFromCoords(configLocation);
                    } else {
                        fetchCoordsFromCity(configLocation);
                    }

                    return;
                }
                if (
                    (!loc || Date.now() - lastAutoLocationTime > 900000) &&
                    !ipApiRequestPending &&
                    Date.now() >= ipApiBlockedUntil
                ) {
                    ipApiRequestPending = true;

                    request(
                        "http://ip-api.com/json?fields=status,message,city,lat,lon",

                        (text, metadata) => {
                            ipApiRequestPending = false;

                            recordIpApiRateLimit(metadata);
                            if (weatherLocation.trim())
                                return;

                            let response;

                            try {
                                response = JSON.parse(text);
                            } catch (error) {
                                console.warn(
                                    "Weather:",
                                    `Unable to parse ip-api response: ${error}`
                                );
                                return;
                            }

                            const lat = Number(response.lat);
                            const lon = Number(response.lon);

                            if (
                                response.status !== "success" ||
                                !Number.isFinite(lat) ||
                                !Number.isFinite(lon)
                            ) {
                                console.warn(
                                    "Weather:",
                                    `ip-api lookup failed: ${response.message ?? "invalid response"}`
                                );

                                return;
                            }

                            city = fixCityName(response.city ?? "");

                            lastAutoLocationTime = Date.now();

                            loc = `${lat},${lon}`;
                        },

                        (error, metadata) => {
                            ipApiRequestPending = false;

                            if (!recordIpApiRateLimit(metadata))
                                console.warn(
                                    "Weather:",
                                    `ip-api request failed: ${error}`
                                );
                        }
                    );
                }
            }

            function recordIpApiRateLimit(metadata): bool {
                if (metadata?.statusCode !== 429)
                    return false;

                const delayMs = 61000;

                ipApiBlockedUntil = Date.now() + delayMs;

                ipApiRetryTimer.interval = delayMs;
                ipApiRetryTimer.restart();

                return true;
            }


            function fixCityName(cityName: string): string {
                if (!cityName)
                    return "";

                const mapping = {
                    // Polish
                    "Poznan": "Poznań",
                    "Wroclaw": "Wrocław",
                    "Krakow": "Kraków",
                    "Gdansk": "Gdańsk",
                    "Lodz": "Łódź",
                    "Rzeszow": "Rzeszów",
                    "Torun": "Toruń",
                    "Bialystok": "Białystok",
                    "Czestochowa": "Częstochowa",
                    "Plock": "Płock",
                    "Ruda Slaska": "Ruda Śląska",
                    "Dabrowa Gornicza": "Dąbrowa Górnicza",
                    "Elblag": "Elbląg",
                    "Gorzow Wielkopolski": "Gorzów Wielkopolski",
                    "Zielona Gora": "Zielona Góra",
                    "Slupsk": "Słupsk",

                    // German
                    "Munchen": "München",
                    "Koln": "Köln",
                    "Dusseldorf": "Düsseldorf",
                    "Nurnberg": "Nürnberg",

                    // French / Spanish / Portuguese
                    "Sao Paulo": "São Paulo",
                    "Montreal": "Montréal",
                    "Quebec": "Québec",
                    "Bogota": "Bogotá",
                    "Medellin": "Medellín",
                    "Cordoba": "Córdoba",

                    // Turkish
                    "Istanbul": "İstanbul",
                    "Izmir": "İzmir",

                    // Scandinavian / others
                    "Malmo": "Malmö",
                    "Goteborg": "Göteborg",
                    "Zurich": "Zürich",
                    "Geneve": "Genève"
                };

                return mapping[cityName] || cityName;
            }


            function cacheCity(coords: string, cityName: string): void {
                cachedCities.set(coords, cityName);
                citiesSaveTimer.restart();
            }


            function fetchCityFromCoords(coords: string): void {
                if (cachedCities.has(coords)) {
                    city = cachedCities.get(coords);
                    return;
                }
                if (!citiesLoaded) {
                    pendingCoords = coords;
                    return;
                }

                const [lat, lon] = coords
                .split(",")
                .map(s => s.trim());

                const lang =
                Qt.locale().name.split("_")[0] || "en";

                const nominatimUrl =
                `https://nominatim.openstreetmap.org/reverse` +
                `?lat=${encodeURIComponent(lat)}` +
                `&lon=${encodeURIComponent(lon)}` +
                `&format=geocodejson` +
                `&accept-language=${encodeURIComponent(lang)}`;

                const nominatimHeaders = {
                    "User-Agent":
                    "dawnbreakos-shell/1.0 (+https://github.com/Hussein-Playz/dawnbreakos)"
                };

                request(
                    nominatimUrl,

                    text => {
                        let geo;

                        try {
                            geo =
                            JSON.parse(text)
                            .features?.[0]
                            ?.properties
                            ?.geocoding;
                        } catch (error) {
                            console.warn(
                                "Weather:",
                                `Unable to parse Nominatim response: ${error}`
                            );

                            city = "Unknown city";
                            return;
                        }

                        if (geo) {
                            const geoCity =
                            geo.type === "city"
                            ? geo.name
                            : geo.city;

                            if (geoCity) {
                                city = fixCityName(geoCity);

                                cacheCity(coords, city);

                                return;
                            }
                        }

                        console.warn(
                            "Weather:",
                            "No locality in Nominatim response"
                        );

                        city = "Unknown city";
                    },

                    error => {
                        console.warn(
                            "Weather:",
                            `Nominatim request failed: ${error}`
                        );

                        city = "Unknown city";
                    },

                    nominatimHeaders
                );
            }

            function fetchCoordsFromCity(cityName: string): void {
                const lang =
                Qt.locale().name.split("_")[0] || "en";

                const url =
                `https://geocoding-api.open-meteo.com/v1/search` +
                `?name=${encodeURIComponent(cityName)}` +
                `&count=1` +
                `&language=${encodeURIComponent(lang)}` +
                `&format=json`;

                request(url, text => {
                    let json;

                    try {
                        json = JSON.parse(text);
                    } catch (error) {
                        console.warn(
                            "Weather:",
                            `Unable to parse geocoding response: ${error}`
                        );

                        return;
                    }

                    if (
                        json.results &&
                        json.results.length > 0
                    ) {
                        const result = json.results[0];

                        loc =
                        result.latitude +
                        "," +
                        result.longitude;

                        city = fixCityName(result.name);
                    } else {
                        loc = "";

                        reload();
                    }
                });
            }

            function fetchWeatherData(): void {
                const url = getWeatherUrl();

                if (url === "")
                    return;

                request(url, text => {
                    let json;

                    try {
                        json = JSON.parse(text);
                    } catch (error) {
                        console.warn(
                            "Weather:",
                            `Unable to parse weather response: ${error}`
                        );

                        return;
                    }

                    if (!json.current || !json.daily)
                        return;

                    cc = {
                        weatherCode:
                        json.current.weather_code,

                        tempC:
                        json.current.temperature_2m,

                        feelsLikeC:
                        json.current.apparent_temperature,

                        humidity:
                        json.current.relative_humidity_2m,

                        windSpeed:
                        json.current.wind_speed_10m,

                        isDay:
                        json.current.is_day,

                        sunrise:
                        json.daily.sunrise[0]
                        .replace("T", " "),

                        sunset:
                        json.daily.sunset[0]
                        .replace("T", " ")
                    };

                    const forecastList = [];

                    for (
                        let i = 0;
                    i < json.daily.time.length;
                    i++
                    ) {
                        forecastList.push({
                            date:
                            json.daily.time[i]
                            .replace(/-/g, "/"),

                                          maxTempC:
                                          json.daily.temperature_2m_max[i],

                                          minTempC:
                                          json.daily.temperature_2m_min[i],

                                          weatherCode:
                                          json.daily.weather_code[i],

                                          icon:
                                          getWeatherIcon(
                                              json.daily.weather_code[i]
                                          )
                        });
                    }

                    forecast = forecastList;


                    const hourlyList = [];
                    const now = new Date();

                    for (
                        let i = 0;
                    i < json.hourly.time.length;
                    i++
                    ) {
                        const time =
                        new Date(
                            json.hourly.time[i]
                            .replace("T", " ")
                        );

                        if (time < now)
                            continue;

                        hourlyList.push({
                            timestamp:
                            json.hourly.time[i],

                            hour:
                            time.getHours(),

                                        tempC:
                                        Math.round(
                                            json.hourly
                                            .temperature_2m[i]
                                        ),

                                        precipChance:
                                        json.hourly
                                        .precipitation_probability[i],

                                        weatherCode:
                                        json.hourly
                                        .weather_code[i],

                                        icon:
                                        getWeatherIcon(
                                            json.hourly
                                            .weather_code[i]
                                        )
                        });
                    }

                    hourlyForecast = hourlyList;
                });
            }

            function getWeatherUrl(): string {
                if (
                    !loc ||
                    loc.indexOf(",") === -1
                ) {
                    return "";
                }

                const [lat, lon] = loc
                .split(",")
                .map(s => s.trim());

                const baseUrl =
                "https://api.open-meteo.com/v1/forecast";

                const params = [
                    "latitude=" + encodeURIComponent(lat),
                    "longitude=" + encodeURIComponent(lon),

                    "hourly=" +
                    "weather_code," +
                    "temperature_2m," +
                    "precipitation_probability",

                    "daily=" +
                    "weather_code," +
                    "temperature_2m_max," +
                    "temperature_2m_min," +
                    "sunrise," +
                    "sunset",

                    "current=" +
                    "temperature_2m," +
                    "relative_humidity_2m," +
                    "apparent_temperature," +
                    "is_day," +
                    "weather_code," +
                    "wind_speed_10m",

                    "timezone=auto",

                    "forecast_days=7"
                ];

                return baseUrl + "?" + params.join("&");
            }

            function getWeatherIcon(code): string {
                const icons = {
                    0: "clear_day",

                    1: "clear_day",

                    2: "partly_cloudy_day",

                    3: "cloud",

                    45: "foggy",

                    48: "foggy",

                    51: "rainy",

                    53: "rainy",

                    55: "rainy",

                    56: "weather_mix",

                    57: "weather_mix",

                    61: "rainy",

                    63: "rainy",

                    65: "rainy",

                    66: "rainy",

                    67: "rainy",

                    71: "snowing",

                    73: "snowing",

                    75: "snowing",

                    77: "snowing",

                    80: "rainy",

                    81: "rainy",

                    82: "rainy",

                    85: "weather_snowy",

                    86: "weather_snowy",

                    95: "thunderstorm",

                    96: "thunderstorm",

                    99: "thunderstorm"
                };

                return icons[Number(code)] || "cloud";
            }

            function getWeatherCondition(code): string {
                const conditions = {
                    0: "Clear",
                    1: "Clear",

                    2: "Partly cloudy",

                    3: "Overcast",

                    45: "Fog",
                    48: "Fog",

                    51: "Drizzle",
                    53: "Drizzle",
                    55: "Drizzle",

                    56: "Freezing drizzle",
                    57: "Freezing drizzle",

                    61: "Light rain",
                    63: "Rain",
                    65: "Heavy rain",

                    66: "Light rain",
                    67: "Heavy rain",

                    71: "Light snow",
                    73: "Snow",
                    75: "Heavy snow",
                    77: "Snow",

                    80: "Light rain",
                    81: "Rain",
                    82: "Heavy rain",

                    85: "Light snow showers",
                    86: "Heavy snow showers",

                    95: "Thunderstorm",

                    96: "Thunderstorm with hail",
                    99: "Thunderstorm with hail"
                };

                return conditions[Number(code)] || "Unknown";
            }

            /*
             * ================================================================
             * LOCATION CHANGED
             * ================================================================
             */

            onLocChanged: fetchWeatherData()

            onCitiesLoadedChanged: {
                if (!citiesLoaded || !pendingCoords)
                    return;

                const coords = pendingCoords;

                pendingCoords = "";

                fetchCityFromCoords(coords);
            }


            Timer {
                interval: 3600000
                running: true
                repeat: true

                onTriggered: root.fetchWeatherData()
            }


            Timer {
                id: ipApiRetryTimer

                repeat: false

                onTriggered: {
                    const remaining =
                    root.ipApiBlockedUntil -
                    Date.now();

                    if (remaining > 0) {
                        interval =
                        Math.ceil(remaining);

                        restart();
                    } else {
                        root.reload();
                    }
                }
            }


            Timer {
                id: citiesSaveTimer

                interval: 1000
                repeat: false

                onTriggered: {
                    if (!root.citiesLoaded)
                        return;

                    const data = {};

                    root.cachedCities.forEach(
                        (cityName, coords) => {
                            data[coords] = cityName;
                        }
                    );

                    citiesStorage.setText(
                        JSON.stringify(data)
                    );
                }
            }

            FileView {
                id: citiesStorage

                printErrors: false

                path:
                StandardPaths.writableLocation(
                    StandardPaths.CacheLocation
                ) + "/dawnbreakos-weather-cities.json"

                onLoaded: {
                    try {
                        const data =
                        JSON.parse(text());

                        for (
                            const [coords, cityName]
                            of Object.entries(data)
                        ) {
                            if (
                                !root.cachedCities.has(coords)
                            ) {
                                root.cachedCities.set(
                                    coords,
                                    cityName
                                );
                            }
                        }
                    } catch (error) {
                        console.warn(
                            "Weather:",
                            `Unable to parse cached cities: ${error}`
                        );
                    }

                    root.citiesLoaded = true;
                }

                onLoadFailed: err => {
                    root.citiesLoaded = true;

                    if (
                        err ===
                        FileViewError.FileNotFound
                    ) {
                        Qt.callLater(
                            () => setText("{}")
                        );
                    } else {
                        console.warn(
                            "Weather:",
                            `Unable to load cached cities: ${err}`
                        );
                    }
                }
            }

            /*
             * ================================================================
             * STARTUP
             * ================================================================
             */

            Component.onCompleted: {
                root.reload();
            }
}
