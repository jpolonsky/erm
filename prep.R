    ## Create lists of variables of interest
    list_var <- c('Recipient country', 'Donor', 'Type of appeal issued', 'Amount in US$')
    
    ## Restrict dataframe to variables of interest
    df_selectionx <- df_raw[, list_var]
    names(df_selectionx) <- c('country', 'donor', 'appeal', 'amount_received')
    
    if (df_extra$Status %in% 'Contribution' %>% grep(T, .) %>% length(.)) {
      
      df_extra <- df_extra[df_extra$Status %in% 'Contribution', c(3, 5, 7, 9)]
      names(df_extra) <- c('country', 'donor', 'appeal', 'amount_received')
      
      df_selection <- rbind(df_selectionx, df_extra)
      
    } else {
      
      df_selection <- df_selectionx
      
    }
    
    names(df_filter) <- c('appeal', 'status', 'amount_requested')
    
    ## Merge datasets to restrict to appeals of interest
    df <- merge(df_filter, df_selection)
    
    list_status <- c('L3', 'L2', 'Priority', 'Other') %>% factor(.)
    list_country <- df$country %>% unique(.) %>% sort(.)
    list_donor <- df$donor %>% unique(.) %>% sort(.)
    list_appeal <- df$appeal %>% unique(.) %>% sort(.)
    
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
    
    df_total$appeal <- factor(df_total$appeal, levels = df_total$appeal)
    
    df_total$status <- factor(df_total$status, levels = c('L3', 'L2', 'Priority', 'Other'))
    df_total <- df_total[order(df_total$status, desc(df_total$prop_funded)), ]
    names(df_total) <- c('Appeal', 'Crisis type', 'Amount requested', 'Amount received', 'Funded (%)')
    
    return(list(df_total, df_donor, df_filter))
