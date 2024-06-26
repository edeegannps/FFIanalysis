####DBH analysis

rm(list = ls())

library(tidyverse)
library(ggforce)
library(stringr)
library(dplyr)

#set working directory
setwd("C:/Users/edeegan/OneDrive - DOI/FFIanalysis/Analysis/")
##histograms of size composition over years

tree=read.csv("C:/Users/edeegan/OneDrive - DOI/Fire_project/Fire_project/SAGU_data/PSME/PSME_Trees - Individuals (metric)_XPT.csv")
tree$Date_format=as.Date(tree$Date, format="%m/%d/%Y")
tree$Year=str_split_i(tree$Date_format, "-", 1)

tree=tree[which(tree$Status=="L"),]

early_ss=tree[which(tree$Year %in% c("1990", "1991", "1992")), ]
tree=tree[-which(tree$Year %in% c("1990", "1991", "1992")), ]
early_ss$Year="1992"
tree=rbind(early_ss,tree)



#labeling by size class
#pole is less than 15.1
#medium is between 15.1 and 30
#overstory is over 30

for(x in 1:nrow(tree)){
  if(is.na(tree[x, "DBH"])){
    tree[x, "SizeClass"]="NA"
  }else{
    if(tree[x, "DBH"]<=15.1){
      #pole tree
      tree[x, "SizeClass"]="Pole (<15.1)"
    }else if(15.1<tree[x, "DBH"] & tree[x, "DBH"]<30){
      #medium tree
      tree[x, "SizeClass"]="Medium (<30)"
    }else{
      #overstory tree
      tree[x, "SizeClass"]="Overstory (30<)"
    }
    
  }
}

tree=tree %>% drop_na(DBH)
tree=tree %>% mutate(DBH=round(DBH, 0))

#density calculation
tree_1=tree %>% mutate(density=1/(tree$SubFrac*0.24710538))

ggplot(tree_1, aes(x=DBH, y=density, fill=SizeClass))+
  geom_histogram(stat="identity")+
  facet_grid(~Year)+theme_classic()+ylab("Total Density (stems/acre)")+xlab("DBH")+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


#group by size class - count then do density

tree_2=tree %>% mutate(acres=0.24710538*tree$SubFrac) %>% group_by(Year, SizeClass, acres, MacroPlot.Name) %>% count() %>% mutate(density=n/acres)
tree_2=tree_2 %>% group_by(Year, SizeClass) %>% summarize_at(vars(density), list(average_density=mean))
level_order <- c('Pole (<15.1)', 'Medium (<30)', 'Overstory (30<)') 

ggplot(tree_2, aes(x=factor(SizeClass, level_order), y=average_density, fill=SizeClass))+
  geom_histogram(stat="identity")+
  facet_grid(~Year)+theme_classic()+ylab("Average Density (stems/acre)")+xlab("Size Class")+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggsave("PSME_Finalized_Plots/Dead_tree_size_histogram.png", width=15, height=5)



#group by plot - count then do density

tree_3=tree %>% group_by(Year, SizeClass, MacroPlot.Name, SubFrac) %>% count() %>% mutate(acres=0.24710538*SubFrac) %>% mutate(density=n/acres)
level_order <- c('Pole (<15.1)', 'Medium (<30)', 'Overstory (30<)') 

ggplot(tree_3, aes(x=factor(MacroPlot.Name), y=density, fill=SizeClass))+
  geom_histogram(stat="identity")+
  facet_grid(~Year)+theme_classic()+ylab("Density (stems/acre)")+xlab("Size Class")+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


ggsave("PSME_Finalized_Plots/Dead_tree_size_histogram.png", width=15, height=5)

#boxplot of every year and size class combo

tree_4=tree %>% group_by(Year, SizeClass, MacroPlot.Name, SubFrac) %>% count() %>% 
  mutate(acres=0.24710538*SubFrac) %>% mutate(density=n/acres) %>%
  group_by(Year, SizeClass) %>% summarize(density_sum=sum(density))


tree_4 %>% ggplot(aes(x=Year, y=density_sum))+geom_bar(stat="identity")

tree_5=tree %>% group_by(Year, SizeClass, MacroPlot.Name, SubFrac) %>% count() %>% 
  mutate(acres=0.24710538*SubFrac) %>% mutate(density=n/acres)

tree_5 %>% ggplot(aes(x=Year, y=density, fill=factor(SizeClass, level=level_order)))+geom_boxplot()
                
                