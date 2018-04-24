library(ggplot2)
library(ggmap)

new <- read.csv('newhousing.csv')
new$X <- NULL
rehab <- read.csv('rehabhousing.csv')
rehab$X <- NULL

#34.0522, 118.2437 are the coordinates of Los Angeles
#la <- get_map(location=c(lon=-118.2437,lat=34.0522), maptype="hybrid")
la <- get_googlemap(center=c(lon=-118.2437,lat=34.0522),zoom=10)

#===================================== Basic Plots ========================================================================
new_plot <- ggmap(la) + geom_point(aes(x=longitude,y=latitude,color=Permit.Sub.Type),alpha=0.5,size=1,data=new)
new_plot
rehab_plot <- ggmap(la) + geom_point(aes(x=longitude,y=latitude,color=Permit.Sub.Type),alpha=0.3,size=0.3,data=rehab)
rehab_plot

# Heat Maps
new_heat <- ggmap(la) + geom_density2d(data = new, aes(x = longitude, y = latitude), size = 0.3) + stat_density2d(data = new, aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = "polygon") + scale_fill_gradient(low = "yellow", high = "red") + scale_alpha(range = c(0, 0.3), guide = FALSE)
rehab_heat <- ggmap(la) + geom_density2d(data = rehab, aes(x = longitude, y = latitude), size = 0.3) + stat_density2d(data = rehab, aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = "polygon") + scale_fill_gradient(low = "yellow", high = "red") + scale_alpha(range = c(0, 0.3), guide = FALSE)


#===================================== Choropleth of Council Districts ====================================================
# Shapefiles acquired from https://egis3.lacounty.gov/dataportal/2012/08/07/la-city-council-districts-2012/
library(rgeos)
library(maptools)
library(sp)
la_shapefile <- 'CouncilDistricts/CnclDist_July2012.shp'
la_shp <- rgdal::readOGR(la_shapefile)
la_shp <- spTransform(la_shp,"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") # change long lat axes to decimal
sh2 <- la_shp # make a copy
sh2$DISTRICT <- as.integer(sh2$DISTRICT)
points <- fortify(sh2, region = 'DISTRICT') # Transform shapefile into dataframe so that it can be used with ggmap
points$id <- as.numeric(points$id)

# New housing
# Set scale for palette
tot <- as.numeric(table(new$Council.District))
# Scale the counts EDIT: not necessary
#cols <- (tot - min(tot))/diff(range(tot))*127+1 
cols <- tot
points$total_new <- cols[points$id]
ggmap(la) + geom_polygon(aes(x=long,y=lat, group=group, alpha=0.1, fill=total_new), data=points, color='black') + scale_fill_gradient(low='white', high='red',guide = guide_colorbar(title='New Building Permits')) + guides(size = "legend", alpha = "none")

# Rehab housing
tot <- as.numeric(table(rehab$Council.District))
points$total_rehab<- tot[points$id]
ggmap(la) + geom_polygon(aes(x=long,y=lat, group=group, alpha=0.1, fill=total_rehab), data=points, color='black') + scale_fill_gradient(low='white', high='red',guide = guide_colorbar(title='Altered/Repaired Building Permits')) + guides(size = "legend", alpha = "none")

# Aesthetics
# multiplot(newbldg_heatmap,rehab_heatmap,cols=2)
#Winston Chang's multiplot function
#http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
multiplot <- function(..., plotlist=NULL, cols) {
  require(grid)
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  numPlots = length(plots)
  # Make the panel
  plotCols = cols                          # Number of columns of plots
  plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols
  # Set up the page
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
  vplayout <- function(x, y)
    viewport(layout.pos.row = x, layout.pos.col = y)
  # Make each plot, in the correct location
  for (i in 1:numPlots) {
    curRow = ceiling(i/plotCols)
    curCol = (i-1) %% plotCols + 1
    print(plots[[i]], vp = vplayout(curRow, curCol ))
  }
  
}