####DBH analysis

tree=read.csv("C:/Users/edeegan/OneDrive - DOI/Fire_project/Fire_project/SAGU_data/PSME/PSME_Trees - Individuals (metric)_XPT.csv")

library(tidyverse)
library(ggforce)

tree$Date_format=as.Date(tree$Date, format="%m/%d/%Y")
library(stringr)

tree$Year=str_split_i(tree$Date_format, "-", 1)



p.list = lapply(sort(unique(tree$MacroPlot.Name)), function(i) {
  ggplot(tree[tree$MacroPlot.Name==i,], aes(x=Year, y=DBH, group=TagNo, color=as.factor(TagNo)))+
    geom_line(linetype=2)+geom_point(size=1.5)+
    facet_wrap_paginate(~MacroPlot.Name)+
    theme(legend.position="none")+
    theme_classic()
  
})

p.list[[1]]
p.list[[2]]
p.list[[3]]
p.list[[4]]
p.list[[5]]


#color for increase, decrease, stay the same


library(dplyr)

years=sort(unique(tree$Year))

tree$dbh_change=NA

tree[which(tree$Year==1990), "dbh_change"]="no_change"


for(x in 2:length(years)){
  previous_year=years[x-1]
  trees_p=tree[which(tree$Year==previous_year),"TagNo"]
  current_year=years[x]
  trees_c=tree[which(tree$Year==current_year), "TagNo"]
  
  trees_c=intersect(trees_p, trees_c)
  
  for(i in 1:length(trees_c)){
    current_dbh=tree[which(tree$TagNo==trees_c[i] & tree$Year==current_year), "DBH"]
    previous_dbh=tree[which(tree$TagNo==trees_c[i] & tree$Year==previous_year), "DBH"]
    
    if(length(current_dbh)==0 | length(previous_dbh)==0){
      #do nothing?
    }else{
      
      if(length(current_dbh)>1 | length(previous_dbh)>1){
        current_dbh=unique(current_dbh)
        current_dbh=current_dbh[1]
        previous_dbh=unique(previous_dbh)
        previous_dbh=previous_dbh[1]}
      
      if(is.na(previous_dbh) | is.na(current_dbh)){
        tree[which(tree$TagNo==trees_c[i] & tree$Year==current_year), "dbh_change"]="NA"
      }else{
        
        if(previous_dbh<current_dbh){
          #increase
          tree[which(tree$TagNo==trees_c[i] & tree$Year==current_year), "dbh_change"]="increase"
        }else if(previous_dbh>current_dbh){
          #decrease
          tree[which(tree$TagNo==trees_c[i] & tree$Year==current_year), "dbh_change"]="decrease"
        }else if(previous_dbh==current_dbh){
          #stay same
          tree[which(tree$TagNo==trees_c[i] & tree$Year==current_year), "dbh_change"]="same"
        }
      }
    }
    
  } 
}

tree[which(tree$dbh_change=="no_change" |is.na(tree$dbh_change)), "dbh_change"]="NA"

ggplot(tree, aes(x=Year, y=DBH, group=TagNo, color=dbh_change, alpha=Status))+
  geom_point(size=1.5)+theme_classic()+scale_color_manual(values=c("darkblue", "lightblue", "lightgrey", "red"))


p.list = lapply(sort(unique(tree$MacroPlot.Name)), function(i) {
  ggplot(tree[tree$MacroPlot.Name==i,], aes(x=Year, y=DBH, group=TagNo, color=dbh_change, alpha=Status))+
    geom_point(size=1.5)+theme_classic()+
    scale_color_manual(values=c("darkblue", "lightblue", "lightgrey", "red"))+
    facet_wrap_paginate(~MacroPlot.Name)+
    theme_classic()
  
})

p.list[[1]]
p.list[[2]]
p.list[[3]]
p.list[[4]]
p.list[[5]]
p.list[[6]]
p.list[[7]]
p.list[[8]]
p.list[[9]]
p.list[[10]]



post_fire=tree[which(tree$Year=="2001" | tree$Year=="2003" | tree$Year=="2004"), ]

ggplot(post_fire, aes(x=Year, y=DBH, group=TagNo,alpha=Status))+
  geom_point(aes(size=0.1, color=dbh_change))+theme_classic()+scale_color_manual(values=c("darkblue", "lightblue", "lightgrey", "red"))


ggplot(tree, aes(x=Year, y=DBH, group=TagNo,alpha=Status, color=dbh_change))+geom_line()+
  geom_point(aes(size=0.05))+theme_classic()+scale_color_manual(values=c("darkblue", "lightblue", "lightgrey", "red"))


##histograms of size composition over years

tree=read.csv("C:/Users/edeegan/OneDrive - DOI/Fire_project/Fire_project/SAGU_data/PSME/PSME_Trees - Individuals (metric)_XPT.csv")
tree$Date_format=as.Date(tree$Date, format="%m/%d/%Y")
tree$Year=str_split_i(tree$Date_format, "-", 1)

tree=tree[which(tree$Status=="D"),]

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

ggplot(tree, aes(DBH, fill=SizeClass))+geom_histogram(bins=50)+facet_grid(~Year)+theme_classic()+ylim(0,51)

ggsave("PSME_Finalized_Plots/Dead_tree_size_histogram.png", width=15, height=5)

#same but for dead trees
tree=read.csv("C:/Users/edeegan/OneDrive - DOI/Fire_project/Fire_project/SAGU_data/PSME/PSME_Trees - Individuals (metric)_XPT.csv")
tree$Date_format=as.Date(tree$Date, format="%m/%d/%Y")
tree$Year=str_split_i(tree$Date_format, "-", 1)

tree=tree[which(tree$Status=="D"),]

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

ggplot(tree, aes(DBH, fill=SizeClass))+geom_histogram(bins=50)+facet_grid(~Year)+theme_classic()

ggsave("PSME_Finalized_Plots/Dead_tree_size_histogram.png", width=15, height=5)



