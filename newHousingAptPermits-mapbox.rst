
.. code:: ipython2

    import plotly.plotly as py
    from plotly.graph_objs import *
    import pandas as pd
    import os
    os.chdir('/Users/connorvhennen/Desktop/Classes W18/Stat 141SL/Project')
    
    newHousing = pd.read_csv('newhousing.csv')
    rehabHousing = pd.read_csv('rehabhousing.csv')

.. code:: ipython2

    rehabHousing.dropna(subset=['latitude'])
    newHousing.dropna(subset=['latitude'])
    rehabHousing = rehabHousing.reset_index(drop=True)
    newHousing = newHousing.reset_index(drop=True)

.. code:: ipython2

    newHousingPerms = set(newHousing['Permit.Sub.Type'])
    rehabHousingPerms = set(rehabHousing['Permit.Sub.Type'])

.. code:: ipython2

    rehabHousingPerms




.. parsed-literal::

    {'1 or 2 Family Dwelling', 'Apartment'}



.. code:: ipython2

    newFamDwell = []
    newApt = []
    
    for i in range(len(list(newHousing['Permit.Sub.Type']))):
        if newHousing.ix[i,'Permit.Sub.Type'] == '1 or 2 Family Dwelling':
            newFamDwell.append(i)
        if newHousing.ix[i,'Permit.Sub.Type'] == 'Apartment':
            newApt.append(i)
    
    rehabFamDwell = []
    rehabApt = []
    for i in range(len(list(rehabHousing['Permit.Sub.Type']))):
        if rehabHousing.ix[i,'Permit.Sub.Type'] == '1 or 2 Family Dwelling':
            rehabFamDwell.append(i)
        if rehabHousing.ix[i,'Permit.Sub.Type'] == 'Apartment':
            rehabApt.append(i)
        


.. parsed-literal::

    /Users/connorvhennen/anaconda2/lib/python2.7/site-packages/ipykernel_launcher.py:5: DeprecationWarning:
    
    
    .ix is deprecated. Please use
    .loc for label based indexing or
    .iloc for positional indexing
    
    See the documentation here:
    http://pandas.pydata.org/pandas-docs/stable/indexing.html#ix-indexer-is-deprecated
    
    /Users/connorvhennen/anaconda2/lib/python2.7/site-packages/ipykernel_launcher.py:13: DeprecationWarning:
    
    
    .ix is deprecated. Please use
    .loc for label based indexing or
    .iloc for positional indexing
    
    See the documentation here:
    http://pandas.pydata.org/pandas-docs/stable/indexing.html#ix-indexer-is-deprecated
    


.. code:: ipython2

    newFamHousing = newHousing.drop(newHousing.index[newApt])
    newAptHousing = newHousing.drop(newHousing.index[newFamDwell])
    
    rehabFamHousing = rehabHousing.drop(rehabHousing.index[rehabApt])
    rehabAptHousing = rehabHousing.drop(rehabHousing.index[rehabFamDwell])

.. code:: ipython2

    print rehabAptHousing.shape[0]
    print newAptHousing.shape[0]
    print rehabFamHousing.shape[0]
    print newFamHousing.shape[0]


.. parsed-literal::

    27496
    1221
    106044
    15243


.. code:: ipython2

    106044/27496




.. parsed-literal::

    3



.. code:: ipython2

    import statistics as stats
    l1 = list(rehabAptHousing['longitude'])
    l2 = list(rehabFamHousing['longitude'])
    joinedList = l1+ l2
    medianLongRehab = stats.median(joinedList)
    
    l1 = list(rehabAptHousing['latitude'])
    l2 = list(rehabFamHousing['latitude'])
    joinedList = l1+ l2
    medianLatRehab = stats.median(joinedList)
    
    
    l1 = list(newAptHousing['longitude'])
    l2 = list(newFamHousing['longitude'])
    joinedList = l1+ l2
    medianLongNew = stats.median(joinedList)
    
    l1 = list(newAptHousing['latitude'])
    l2 = list(newFamHousing['latitude'])
    joinedList = l1+ l2
    medianLatNew = stats.median(joinedList)


.. code:: ipython2

    mapbox_access_token ='pk.eyJ1IjoiY29ubm9ydmhlbm5lbiIsImEiOiJjamYyaWE0MnQwMmplMnFuODB6dnFhMWJuIn0.GJzAt8Tj5YLY3GlxKuhK3Q'
    
    newFamHousing['Text'] = newFamHousing['Permit.Sub.Type'] + '<br>Zip Code: ' + newFamHousing['Zip.Code'].astype('str')
    newAptHousing['Text'] = newAptHousing['Permit.Sub.Type'] + '<br>Zip Code: ' + newAptHousing['Zip.Code'].astype('str')
    
    data1 = Data([
        Scattermapbox(
            lat=newFamHousing['latitude'],
            lon=newFamHousing['longitude'],
            mode='markers',
            marker=Marker(
                size=5,
                color = 'rgb(0, 177, 172)'
            ),
            name = 'New 1 or 2 Family Dwelling',
    
            text=newFamHousing['Text'],
        ),
        Scattermapbox(
            lat=newAptHousing['latitude'],
            lon=newAptHousing['longitude'],
            mode='markers',
            marker=Marker(
                size=5,
                color = 'rgb(242, 0, 172)'
            ),
            name = 'New Apartment',
    
            text=newAptHousing['Text'],
            
        )
        
    ])
    layout1 = Layout(
        width = 800,
        height = 900,
        hovermode='closest',
        showlegend=True,
        mapbox=dict(
    
            accesstoken=mapbox_access_token,
            bearing=0,
            center=dict(
                lat=medianLatNew,
                lon = medianLongNew
            ),
            pitch=0,
            zoom=9,
            style = 'light'
        ),
    )
    
    fig = dict(data=data1, layout=layout1)
    py.iplot(fig, filename='New Housing Construction Subpermit Type Distribution')




.. raw:: html

    <iframe id="igraph" scrolling="no" style="border:none;" seamless="seamless" src="https://plot.ly/~connorvhennen/16.embed" height="900px" width="800px"></iframe>



.. code:: ipython2

    "Visit interactive map here:"

.. code:: ipython2

    "https://plot.ly/create/?fid=connorvhennen:16"

.. code:: ipython2

    import random
    #Scattermapbox is really lame in terms of how many data points it can take on. I have no idea why plotly puts it up
    random.seed(1)
    rehabFamHousing = rehabFamHousing.reset_index(drop = True)
    randInds = random.sample(range(0,len(rehabFamHousing)),int(len(rehabFamHousing)*.85))
    rehabFamHousing = rehabFamHousing.drop(randInds)
    rehabFamHousing = rehabFamHousing.reset_index(drop = True)
    
    rehabAptHousing = rehabAptHousing.reset_index(drop = True)
    randInds = random.sample(range(0,len(rehabAptHousing)),int(len(rehabAptHousing)*.85))
    rehabAptHousing = rehabAptHousing.drop(randInds)
    rehabAptHousing = rehabAptHousing.reset_index(drop = True)

.. code:: ipython2

    len(rehabFamHousing)




.. parsed-literal::

    15907



.. code:: ipython2

    #mapbox_access_token ='pk.eyJ1IjoiY29ubm9ydmhlbm5lbiIsImEiOiJjamYyaWE0MnQwMmplMnFuODB6dnFhMWJuIn0.GJzAt8Tj5YLY3GlxKuhK3Q'
    mapbox_access_token ='pk.eyJ1IjoiY29ubm9ydmhlbm5lbiIsImEiOiJjamYyaTl4MG0xaHV0MnhvaG1wanN0MmdoIn0.5GTLmy6jdxzNN5JBJC8XYw'
    
    rehabFamHousing['Text'] = rehabFamHousing['Permit.Sub.Type'] + '<br>Zip Code: ' + rehabFamHousing['Zip.Code'].astype('str')
    rehabAptHousing['Text'] = rehabAptHousing['Permit.Sub.Type'] + '<br>Zip Code: ' + rehabAptHousing['Zip.Code'].astype('str')
    
    dataRehabData = Data([
        Scattermapbox(
            lat=rehabFamHousing['latitude'],
            lon=rehabFamHousing['longitude'],
            mode='markers',
            marker=Marker(
                size=5,
                opacity = .4,
            ),
            name = 'Rehabilitated 1 or 2 Family Dwelling',
            text=rehabFamHousing['Text'],
        ),
        Scattermapbox(
            lat=rehabAptHousing['latitude'],
            lon=rehabAptHousing['longitude'],
            mode='markers',
            marker=Marker(
                size=5,
                color = 'rgb(242, 0, 172)',
                opacity = .4
            ),
            name = 'Rehabilitated Apartment',
            text=rehabAptHousing['Text'],
        )
    ])
    layout2 = Layout(
        width = 800,
        height = 900,
        hovermode='closest',
        showlegend=True,
        mapbox=dict(
    
            accesstoken=mapbox_access_token,
            bearing=0,
            center=dict(
                lat=medianLatRehab,
                lon = medianLongRehab
            ),
            pitch=0,
            zoom=8.5,
            style = 'light'
        ),
    )  
    
    fig7 = dict(data=dataRehabData, layout=layout2)
    py.iplot(fig7,filename='Rehab Housing Construction Subpermit Type Distribution')
    #py.image.save_as(fig, filename='rehabPermitDist.png')




.. raw:: html

    <iframe id="igraph" scrolling="no" style="border:none;" seamless="seamless" src="https://plot.ly/~connorvhennen/18.embed" height="900px" width="800px"></iframe>



.. code:: ipython2

    'Visit interactive map here:'

.. code:: ipython2

    "https://plot.ly/create/?fid=connorvhennen:18"
