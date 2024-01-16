####Species composition analysis
#load necessary packages
library(tidyverse)
library(dplyr)
library(stringr)

#clearing environment - fresh start!
rm(list = ls())


#set working directory - CHANGE TO LOCAL SPECIFIC PATH
setwd("C:/Users/edeegan/OneDrive - DOI/Fire_project/Fire_project/")
#load in tree data - CHANGE TO LOCAL SPECIFIC PATH
tree=read.csv("SAGU_data/PSME/PSME_Trees - Individuals (metric)_XPT.csv")

####DELETING PROBLEM TREES FROM DATA


#filtering for only alive trees
tree=tree[which(tree$Status=="L"),]
#taking out canopy data
tree=tree[-which(tree$Species.Symbol=="CANOPY"),]
#formatting date column
tree$Date_format=as.Date(tree$Date, format="%m/%d/%Y")
#creating new column for just year
tree$Year=str_split_i(tree$Date_format, "-", 1)
#counting species for each year and creating new data frame for results
species_summary=tree %>% group_by(Year) %>% count(Species.Symbol)

#combining years 1990, 1991, 1992 - SAGUARO SPECIFIC (DELETE FOR OTHER PARKS)

early_ss=species_summary[which(species_summary$Year %in% c("1990", "1991", "1992")), ]
species=unique(early_ss$Species.Symbol)
totals=c()
for(s in 1:length(species)){
  totals=c(totals, sum(early_ss[which(early_ss$Species.Symbol==species[s]),"n"]))
}

early_ss=cbind(c(rep("1992", length(species))), species, totals)
colnames(early_ss)=c("Year", "Species.Symbol", "n")
early_ss=as.data.frame(early_ss)
species_summary=species_summary[-which(species_summary$Year %in% c("1990", "1991", "1992")), ]
species_summary=rbind(early_ss, species_summary)
species_summary$Year=as.character(species_summary$Year)


#calculating total tree count for each year - to be used in percentage calculation
species_summary$n=as.integer(species_summary$n)
species_summary <- species_summary %>%
  group_by(Year) %>%
  mutate(total = sum(n)) %>%
  ungroup()

#calculating species percentage of total for each year
species_summary <- species_summary %>%
  mutate(percent = round(n/total*100, 1))


#renaming species code to common name - CHANGE FOR LOCAL SPECIES
species_summary=species_summary %>%
  mutate(Species.Symbol = recode(Species.Symbol, 
                                 'ABCO1' = 'White Fir', 
                                 'QUGA1' = 'Gambels Oak',
                                 'PIPO1' = 'Ponderosa Pine',
                                 'PIST1' = 'Southwestern White Pine',
                                 'PSME1' = 'Douglas Fir'))




library(egg)
tag_facet2 <- function(p, open = "(", close = ")", tag_pool = letters, x = -Inf, y = Inf, 
                       hjust = -0.5, vjust = 1.5, fontface = 2, family = "", ...) {
  
  gb <- ggplot_build(p)
  lay <- gb$layout$layout
  tags <- cbind(lay, label = paste0(open, tag_pool[lay$PANEL], close), x = x, y = y)
  p + geom_text(data = tags, aes_string(x = "x", y = "y", label = "label"), ..., hjust = hjust, 
                vjust = vjust, fontface = fontface, family = family, inherit.aes = FALSE)
}
#pie chart to show species composition change over time
plot=ggplot(species_summary, aes(x="", y=percent, fill=Species.Symbol)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0)+
  facet_wrap(~Year)+
  geom_text(aes(label = paste(percent, "%")), size=2,position = position_stack(vjust=0.5)) +
  labs(x = NULL, y = NULL, fill = NULL)+theme_bw()+scale_fill_brewer(palette = "PuOr")+
  labs(title = "PSME plots species composition over time")+
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
plot

my_tag <- unique(species_summary$total)
tag_facet2(plot, 
          x = -Inf, y = -Inf, 
          vjust = -8.5, hjust = -3,
          size = 2,
          family = "serif",
          tag_pool = my_tag)
#saving plot - CHANGE TITLE 
ggsave("PSME_species.png")


#glmer with poisson for count data?
