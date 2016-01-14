#This code extracts income and popualtion measures at the zipcode level and outputs a csv and text file
#I found this code at http://amunategui.github.io/ggmap-example/#sourcecode

#require(RCurl)
#require(xlsx)

# NOTE if you can't download the file automatically, download it manually at:
# 'http://www.psc.isr.umich.edu/dis/census/Features/tract2zip/'
urlfile <-'http://www.psc.isr.umich.edu/dis/census/Features/tract2zip/MedianZIP-3.xlsx'
destfile <- "census20062010.xlsx"
download.file(urlfile, destfile, mode="wb")
census <- read.xlsx2(destfile, sheetName = "Median")

# clean up data
census <- census[c('Zip','Median..', 'Pop')]
names(census) <- c('Zip','Median', 'Pop')
census$Median <- as.character(census$Median)
census$Median <- as.numeric(gsub(',','',census$Median))
print(head(census,5))


# get geographical coordinates from zipcode
#require(zipcode)
data(zipcode)
census$Zip <- clean.zipcodes(census$Zip)
census <- merge(census, zipcode, by.x='Zip', by.y='zip')

# get a Google map
require(ggmap)
map<-get_map(location='united states', zoom=4, maptype = "terrain",
             source='google',color='color')

# plot it with ggplot2
require("ggplot2")
ggmap(map) + geom_point(
  aes(x=longitude, y=latitude, show_guide = TRUE, colour=Median), 
  data=census, alpha=.8, na.rm = T)  + 
  scale_color_gradient(low="beige", high="blue")

#save newly created file to csv
getwd()
write.csv(census, file="/Users/briansaindon/desktop/files/NYCDSA/datasci4good/alz/data/medianincomebyzip.csv")
write.table(census, file="/Users/briansaindon/desktop/files/NYCDSA/datasci4good/alz/data/medianincomebyzip.txt", sep="\t")
