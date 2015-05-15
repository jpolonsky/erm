# Load required packages
if(!require(XLConnect)) {install.packages("XLConnect"); require(XLConnect)}
# if(!require(xlsx)) {install.packages("xlsx"); require(xlsx)}
if(!require(ggplot2)) {install.packages("ggplot2"); require(ggplot2)}
if(!require(dplyr)) {install.packages("dplyr"); require(dplyr)}
if(!require(reshape2)) {install.packages("reshape2"); require(reshape2)}
if(!require(scales)) {install.packages("scales"); require(scales)}
if(!require(RColorBrewer)) {install.packages("RColorBrewer"); require(RColorBrewer)}
if(!require(xtable)) {install.packages("xtable"); require(xtable)}
# if(!require(extrafont)) {install.packages("extrafont"); require(extrafont)}

# wb <- loadWorkbook('K:/clData/ERM_Financial_Tool/2012 pledges and contributions.xlsx', create = F)
filename <- list.files(path = '.', pattern = "xlsx")
year <- list.files(path = '.', pattern = "txt")
year <- sub('.txt', '', year)

# wb <- loadWorkbook('./2012 pledges and contributions.xlsx', create = F)
wb <- loadWorkbook(filename, create = F)
# df_raw <- readWorksheet(wb, sheet = "Contribution data", startRow = 2)
# df_extra <- readWorksheet(wb, sheet = "Soft pledges-other ctrbns 2015", startRow = 2)
# df_filter <- readWorksheet(wb, sheet = "SRP 2015 funds requested", startRow = 3)

listSheets <- getSheets(wb)
df_raw <- readWorksheet(wb, sheet = listSheets[grep("Contribution", listSheets)], startRow = 2)
df_extra <- readWorksheet(wb, sheet = listSheets[grep(paste0("ctrbns ", year), listSheets)], startRow = 2)
df_filter <- readWorksheet(wb, sheet = listSheets[grep(paste0("SRP ", year), listSheets)], startRow = 3)

# df_raw <- read.xlsx2(filename, sheetName = "Contribution data", startRow = 2)
# df_extra <- read.xlsx2(filename, sheetName = "Soft pledges-other ctrbns 2015", startRow = 2)
# df_filter <- read.xlsx2(filename, sheetName = "SRP 2015 funds requested", startRow = 3)

## Create lists of variables of interest
list_var <- c('Recipient.country', 'Donor', 'Type.of.appeal.issued', 'Amount.in.US.')

## Restrict dataframe to variables of interest
df_selectionx <- df_raw[, list_var]
names(df_selectionx) <- c('country', 'donor', 'appeal', 'amount_received')
head(df_selectionx)

df_extra <- df_extra[df_extra$Status == 'Contribution', c(3, 5, 7, 9)]
names(df_extra) <- c('country', 'donor', 'appeal', 'amount_received')
head(df_extra)

df_selection <- rbind(df_selectionx, df_extra)
head(df_selection)

names(df_filter) <- c('appeal', 'status', 'amount_requested')
head(df_filter)

## Merge datasets to restrict to appeals of interest
df <- merge(df_filter, df_selection)
tail(df)

# df$amount_requested <- as.numeric(levels(df$amount_requested))[df$amount_requested]
# df$amount_received <- as.numeric(levels(df$amount_received))[df$amount_received]

list_status <- factor(c('L3', 'L2', 'Priority', 'Other'))
list_country <- sort(unique(df$country))
list_donor <- sort(unique(df$donor))
list_appeal <- sort(unique(df$appeal))

df_donor <- 
    df %>%
    group_by(appeal, status, donor) %>%
    summarise(total_requested = min(amount_requested, na.rm = T),
              total_received = sum(amount_received, na.rm = T),
              prop_funded = round(sum(amount_received, na.rm = T)/min(amount_requested, na.rm = T)*100, digits = 1)) %>%
    arrange(status, appeal, desc(total_received))

df_donor$prop_funded <- ifelse(df_donor$prop_funded == Inf, 100, df_donor$prop_funded)
df_donor$prop_funded[is.na(df_donor$prop_funded)] <- 0

df_total <- 
  df %>%
  #group_by(country, appeal, status) %>%
  group_by(appeal, status) %>%
  summarise(total_requested = min(amount_requested, na.rm = T),
            total_received = sum(amount_received, na.rm = T),
            prop_funded = round(sum(amount_received, na.rm = T)/min(amount_requested, na.rm = T)*100, digits = 1)) %>%
  arrange(desc(prop_funded), status, appeal)

df_total$prop_funded <- ifelse(df_total$prop_funded == Inf, 100, df_total$prop_funded)
df_total$prop_funded[is.na(df_total$prop_funded)] <- 0

df_total$status <- factor(df_total$status, levels = c('L3', 'L2', 'Priority', 'Other'))
df_total <- arrange(df_total, desc(prop_funded))
df_total <- df_total %>% filter(!is.na(status))

list_appeals_L3 <- sort(unique(df_total$appeal[df_total$status == 'L3']))
list_appeals_priority <- sort(unique(df_total$appeal[df_total$status == 'Priority']))
list_appeals_other <- sort(unique(df_total$appeal[df_total$status == 'Other']))

blues_func <- colorRampPalette(brewer.pal(9, 'Blues'))
red_func <- colorRampPalette(brewer.pal(9, 'Reds'))

func_pie <- function(x, appeal) {
  x <- x[x$appeal == appeal, ]
  #x <- df_donor[df_donor$appeal == 'Central African Republic: SRP 2014', ]
  
  x_melt <- melt(x, id = c('appeal', 'status', 'donor', 'total_requested'))
  
  dat <- x_melt %>%
    mutate(pos = cumsum(value) - 0.5*value)
  
  dat$donor <- factor(dat$donor, levels = dat$donor)
  
  ggplot(dat, aes(x = '', y = value, order = -value, fill = donor)) + 
    geom_bar(width = 1, stat = 'identity', colour = 'white') + 
    coord_polar('y', start = 0) + 
    #scale_fill_discrete() +
    scale_fill_manual(values = blues_func(nrow(dat)/2)) +
    #guides(fill = guide_legend(title = 'Donor', ncol = 2)) +
    theme_bw() +
    theme(panel.border = element_blank(),
          plot.title = element_text(size = 12, face = 'bold', color = 'darkblue'), 
          #plot.title = element_text(family = 'Calibri', size = 12, face = 'bold', color = 'darkblue'), 
          legend.key = element_blank(),
          legend.position = '',
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          panel.grid  = element_blank()) +
    labs(title = paste0('Firm pledges/contributions received\nby WHO: US$', comma(sum(x_melt$value, na.rm = T))), 
         x = '', y = '') 
  
}

#func_pie(df_donor, list_appeal[2])
#func_pie(df_donor, list_appeal[7])

#for (i in list_appeal) {
#    func_pie(df_donor, i)
#    ggsave(file = paste0('fig_', i, '.pdf'), width = 6, height = 4)
#    #embed_fonts(paste0('fig_', i, '.pdf'), outfile = paste0('fig_', i, '_embed.pdf'))
#    print(paste('map of', i))
#}


## Overall snapshots
df_total$appeal <- factor(df_total$appeal, levels = df_total$appeal)

wind_chart <- 
  ggplot(df_total, aes(x = appeal, y = prop_funded, order = -prop_funded, fill = appeal)) + 
  geom_bar(width = 1, stat = 'identity', colour = 'white') + 
  coord_polar("y", start = 0) + 
  scale_fill_manual(values = blues_func(nrow(df_total))) +
  theme_bw() +
  #guides(fill = guide_legend(title = 'Donor', ncol = 2)) +
  theme(panel.border = element_blank(),
        plot.title = element_text(size = 12, face = 'bold', color = 'darkblue'), 
        #plot.title = element_text(family = 'Calibri', size = 12, face = 'bold', color = 'darkblue'), 
        legend.key = element_blank(),
        #legend.position = '',
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.grid  = element_blank()) +
  labs(title = 'Proportion of total amount requested\nalready contributed or firmly pledged, by appeal', 
       x = '', y = '') 

#ggsave(file = 'fig_wind_chart.pdf', width = 6, height = 4)

bar_chart <- 
  #ggplot(df_total, aes(x = appeal, y = prop_funded, order = -prop_funded, fill = appeal)) + 
  ggplot(df_total, aes(x = appeal, y = prop_funded, fill = appeal)) + 
  geom_bar(stat = 'identity', colour = 'white') + 
  scale_fill_manual(values = blues_func(nrow(df_total))) +
  #theme_bw() +
  theme(panel.border = element_blank(),
        plot.title = element_text(size = 12, face = 'bold', color = 'darkblue'), 
        #plot.title = element_text(family = 'Calibri', size = 12, face = 'bold', color = 'darkblue'), 
        legend.key = element_blank(),
        legend.position = '',
        axis.text.x = element_text(size = 7, angle = 45, hjust = 1, colour = 'black'),
        #axis.text = element_blank(),
        #panel.grid  = element_blank(),
        axis.ticks = element_blank()) +
  labs(title = '', x = '', y = 'Funded (%)') 

#ggsave(file = 'fig_bar_chart.pdf', width = 12, height = 8)


# save.image("./2.analysed2015.RData")

