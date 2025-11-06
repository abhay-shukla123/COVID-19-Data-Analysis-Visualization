import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px 
from plotly.subplots import make_subplots
from datetime import datetime
from sqlalchemy import create_engine

covid_df = pd.read_csv("covid_19_india.csv")
covid_df.info()
covid_df.describe()
covid_df.drop(["Sno","Time","ConfirmedIndianNational", "ConfirmedForeignNational"], inplace=True, axis=1)
covid_df['Date'] = pd.to_datetime(covid_df["Date"], format = "%Y-%m-%d")
covid_df.head(10)

#Active Cases
covid_df['Active_Cases'] = covid_df['Confirmed'] - (covid_df['Cured'] + covid_df['Deaths'])
covid_df.tail()

statewise = pd.pivot_table(covid_df, values=["Confirmed", "Deaths", "Cured"], index="State/UnionTerritory", aggfunc="max")
statewise["Recovery Rate"] = statewise["Cured"] * 100/statewise["Confirmed"]
statewise["Mortality Rate"] = statewise["Deaths"] * 100/statewise["Confirmed"]

statewise = statewise.sort_values(by="Confirmed", ascending=False)
bg = statewise.style.background_gradient(cmap="cubehelix")
#print(statewise)



#Top 10 Active cases 2
top_10_activeCases = covid_df.groupby(by= "State/UnionTerritory").max()[["Active_Cases","Date"]].sort_values(by=["Active_Cases"], ascending=False).reset_index()

fig = plt.figure(figsize=(16,9))
plt.title("Top 10 states with most active cases in india", size=25)

ax = sns.barplot(data= top_10_activeCases.iloc[:10], y= "Active_Cases", x="State/UnionTerritory", linewidth = 2 , edgecolor= "Red")
plt.xlabel("States")
plt.ylabel("Total Active Cases")
plt.show()

#top states with highests deaths
top_10_deaths = covid_df.groupby(by="State/UnionTerritory").max()[['Deaths', 'Date']].sort_values(by="Deaths", ascending=False).reset_index()

fig = plt.figure(figsize=(18,5))
plt.title("Top 10 states with most deaths" ,size=25)
ax = sns.barplot(data= top_10_deaths.iloc[:12], y ="Deaths", x = "State/UnionTerritory",linewidth=2, edgecolor= "black")
plt.xlabel("States")
plt.ylabel("Total Death cases")
plt.show()

#Growth Trend
fig = plt.figure(figsize=(12,6))

top_states = covid_df[covid_df["State/UnionTerritory"].isin(
    ["Maharashtra", "Karnataka", "Kerala", "Tamil Nadu", "Uttar Pradesh"]
)]

ax = sns.lineplot(
    data = covid_df,
    x = "Date",
    y = "Active_Cases",
    hue = "State/UnionTerritory"
)

ax.set_title("Top 5 Affected States in India", fontsize=16)



#Second data set
vaccine_df = pd.read_csv("covid_vaccine_statewise.csv")
a = vaccine_df.rename(columns={'Updated On': 'Vaccine_Date'}, inplace=True)
vaccine_df.info
vaccine_df.isnull().sum()
vaccine_df.head()
vaccination = vaccine_df.drop(columns=['Sputnik V (Doses Administered)', 'AEFI', '18-44 Years (Doses Administered)','45-60 Years (Doses Administered)','60+ Years (Doses Administered)'], axis=1 )
male = vaccination["Male(Individuals Vaccinated)"].sum()
female = vaccination["Female(Individuals Vaccinated)"].sum()
fig = px.pie(
    names=["Male", "Female"],
    values=[male, female],
    title="Male and Female Vaccination"
)

fig.show()

#remove rows where state = india 
vaccine = vaccine_df[vaccine_df.State!= 'India']
vaccine.rename(columns={"Total individual Vaccinated" : "Total"}, inplace=True)
# Most Vaccinated States
max_vac = vaccine.groupby('State')['Total'].sum().to_frame('Total')
max_vac = max_vac.sort_values('Total', ascending=False)[:5]

fig = plt.figure(figsize=(10,5))
plt.title("Top 5 Vaccinated States in India", fontsize=20)
x = sns.barplot(
    data=max_vac.iloc[:10],
    y=max_vac.Total,  
    x= max_vac.index, 
    linewidth=2,
    edgecolor="black"
)

plt.xlabel("States", fontsize=14)
plt.ylabel("Vaccination Count", fontsize=14)

plt.show()


# your connection details
username = "postgres"          
password = "abhay123"         
host = "localhost"            
port = "5432"                 
database = "Covid_db"

# rename columns to match SQL table fields
covid_df = covid_df.rename(columns={
    'Date': 'date',
    'State/UnionTerritory': 'state',
    'Confirmed': 'confirmed',
    'Cured': 'cured',
    'Deaths': 'deaths',
    'Active_Cases': 'active_cases'
})

# create engine
engine = create_engine(f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}")

# table name (recommended)
table_name = "covid_cases"

# load dataframe to PostgreSQL
covid_df.to_sql(table_name, engine, if_exists='replace', index=False)

print("Data successfully loaded into table '{}' in database '{}'.".format(table_name, database))



