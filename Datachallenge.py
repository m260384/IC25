import pandas as pd
import sqlite3

date_format = "%m/%d/%Y %I:%M:%S %p"

data = pd.read_csv('data.csv', parse_dates=['Date'], date_parser=lambda x: pd.to_datetime(x, format=date_format, errors='coerce'))

data = data.dropna(subset=['Date'])

data['Month'] = data['Date'].dt.strftime('%Y-%m')
stations = pd.read_csv('stations.csv')

stations = stations.rename(columns={'NAME': 'Station Name', 'X': 'Longitude', 'Y': 'Latitude'})
conn = sqlite3.connect(':memory:')
data.to_sql('traffic_data', conn, index=False, if_exists='replace')

query = """
SELECT 
    Month,
    "Time Period", 
    "Station Name", 
    COUNT(*) AS Count
FROM 
    traffic_data
WHERE 
    Month IS NOT NULL
GROUP BY 
    Month, 
    "Time Period", 
    "Station Name"
"""

count_data = pd.read_sql(query, conn)
conn.close()

merged_data = count_data.merge(stations[['Station Name', 'Latitude', 'Longitude']], on='Station Name', how='left')

merged_data['Month'] = pd.to_datetime(merged_data['Month'] + '-01')

#DC coordinates
dc_min_lat, dc_max_lat = 38.79157, 38.99596
dc_min_lon, dc_max_lon = -77.11981, -76.90917

dc_data = merged_data[
    (merged_data["Latitude"] >= dc_min_lat) & (merged_data["Latitude"] <= dc_max_lat) &
    (merged_data["Longitude"] >= dc_min_lon) & (merged_data["Longitude"] <= dc_max_lon)
]

dc_data.to_csv('dc_only_ridership.csv', index=False)
