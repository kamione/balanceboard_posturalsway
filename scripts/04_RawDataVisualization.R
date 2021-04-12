# Inofrmation ------------------------------------------------------------------
#
# 
# 
# 


# Envirnoment ------------------------------------------------------------------
library(tidyverse)
library(here)
library(haven)
library(ggpubr)


# Data I/O ---------------------------------------------------------------------
datapath <- here("data", "raw", "Lincoln_OriginalData_With_ConvertedData", "Lincoln_ExerciseDB.sav")
sway_data <- read_spss(datapath)


# Basic Demographics -----------------------------------------------------------
hist_a <- sway_data %>%
    gghistogram(x = "Age", fill = "gray90", binwidth = 5, ylab = "Frequency",
                add = "mean", add_density = TRUE) +
        geom_vline(xintercept = max(sway_data$Age), linetype = "dotted") +
        geom_vline(xintercept = min(sway_data$Age), linetype = "dotted")

hist_b <- sway_data %>%
    ggplot(mapping = aes(x = Gender)) +
        geom_bar(width = 0.5, color = "black", fill = "gray90", alpha = 0.5) +
        scale_x_continuous(breaks = c(1, 2), labels = c("Male", "Female")) +
        labs(y = "Frequency") +
        theme_pubr()
    
hist_c <- sway_data %>%
    gghistogram(x = "EducationLevel", fill = "gray90", binwidth = 1,
                ylab = "Frequency", add = "mean", add_density = TRUE) +
    geom_vline(xintercept = max(sway_data$EducationLevel), linetype = "dotted") +
    geom_vline(xintercept = min(sway_data$EducationLevel), linetype = "dotted") +
    labs(x = "Education Level")

hist_d <- sway_data %>%
    gghistogram(x = "DurationOfIllness", fill = "gray90", binwidth = 5,
                ylab = "Frequency", add = "mean", add_density = TRUE) +
    geom_vline(xintercept = max(sway_data$DurationOfIllness), linetype = "dotted") +
    geom_vline(xintercept = min(sway_data$DurationOfIllness), linetype = "dotted") +
    labs(x = "Duration of Illness")

hist_e <- sway_data %>%
    mutate(DurationOfIllness_log = log(DurationOfIllness)) %>% 
    gghistogram(x = "DurationOfIllness_log", fill = "gray90", binwidth = 0.5,
                ylab = "Frequency", add = "mean", add_density = TRUE) +
    labs(x = "Duration of Illness (Log Transformation)")

hist_f <- sway_data %>%
    gghistogram(x = "EquToChlorpromazine", fill = "gray90", binwidth = 50,
                ylab = "Frequency", add = "mean", add_density = TRUE) +
    geom_vline(xintercept = max(sway_data$EquToChlorpromazine, na.rm = TRUE), linetype = "dotted") +
    geom_vline(xintercept = min(sway_data$EquToChlorpromazine, na.rm = TRUE), linetype = "dotted") +
    labs(x = "Chlorpromazine Equivalent")

# plot combined histogram for multiple basic demograhics
hist_title <- sprintf("Histogram of Basic Demographics (N = %d)\n", nrow(sway_data))
ggarrange(hist_a, hist_b, hist_c, hist_d, hist_e, hist_f, ncol = 3, nrow = 2, labels = c("AUTO")) %>% 
    annotate_figure(top = text_grob(hist_title, size = 14, face = "bold")) %>% 
    ggexport(filename = here("figures", "hist_basicdemographic.pdf"), width = 10, height = 5)


# Baseline-FollowUp Visualization

sway_data_long <- sway_data %>%
    select(PCode, starts_with("BL"), starts_with("FU")) %>% 
    pivot_longer(!PCode, names_to = "variable", values_to = "value") %>% 
    separate(variable, c("time", "variable"), sep = "_", extra = "merge")

# plot pre post PANSS
violin_prepost_panss_a <- sway_data_long %>% 
    filter(variable %in% c("PANSS_Pos", "PANSS_Neg")) %>%
    mutate(variable = factor(variable,
                             levels = c("PANSS_Pos", "PANSS_Neg"),
                             labels = c("PANSS Positive Symptoms", "PANSS Negative Symptoms"))) %>% 
    ggviolin(x = "time", y = "value", fill = "time", facet.by = "variable", add = "mean_sd") +
        stat_compare_means(paired = TRUE, label.x = 0.75, label.y = 32) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Score") +
        theme(legend.position = "none")
violin_prepost_panss_b <- sway_data_long %>% 
    filter(variable %in% c( "PANSS_Gen", "PANSS_Total")) %>%
    mutate(variable = factor(variable,
                             levels = c("PANSS_Gen", "PANSS_Total"),
                             labels = c("PANSS General Psychopathology", "PANSS Total"))) %>% 
    ggviolin(x = "time", y = "value", fill = "time", facet.by = "variable", add = "mean_sd") +
        stat_compare_means(paired = TRUE, label.x = 0.75, label.y = 100) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Score") +
        theme(legend.position = "none")
ggarrange(violin_prepost_panss_a, violin_prepost_panss_b, nrow = 2, ncol = 1) %>% 
ggexport(filename = here("figures", "violin_prepost_panss.pdf"))

# plot SAPS 
violin_prepost_saps <- sway_data_long %>% 
    filter(str_detect(variable, "SAPS")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd", panel.labs = c("SANS Total", "SAPS Total")) +
        facet_wrap(variable ~ ., scales = "free", ncol = 3) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_saps, 
         filename = here("figures", "violin_prepost_saps.pdf"), width = 8, height = 5)
ggsave(filename = here("figures", "violin_prepost_saps.png"),
       plot = violin_prepost_saps, width = 8, height = 5)

# plot SANS
violin_prepost_sans <- sway_data_long %>% 
    filter(str_detect(variable, "SANS")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd", panel.labs = c("SANS Total", "SAPS Total")) +
        facet_wrap(variable ~ ., scales = "free", ncol = 3) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_sans, 
         filename = here("figures", "violin_prepost_sans.png"), width = 800, height = 500)
ggexport(violin_prepost_sans, 
         filename = here("figures", "violin_prepost_sans.pdf"), width = 8, height = 5)


# plot pre-post body information
violin_prepost_body <- sway_data_long %>% 
    filter(variable %in% c("Weight", "Hip", "Waist", "BMI", "WHRatio")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 3) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_body, 
         filename = here("figures", "violin_prepost_body.pdf"), width = 8, height = 5)

# plot pre-post general function
violin_prepost_genfun <- sway_data_long %>% 
    filter(variable %in% c("SOFAS", "GAF", "SOFAS2", "GAF2")) %>%
    mutate(variable = recode(variable, "SOFAS2" = "SOFAS", "GAF2" = "GAF")) %>% 
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 2) +
        stat_compare_means(label.x = 0.75, label.y = 90) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_genfun, 
         filename = here("figures", "violin_prepost_genfun.pdf"), width = 8, height = 5)

# plot pre-post cognitive measures
violin_prepost_cog <- sway_data_long %>% 
    filter(variable %in% c("DigitForward", "DigitBackward", "DigitDifference",
                           "DigitSymbolCoding", "CancellationTask",
                           "LogicalMemory0m", "LogicalMemory30m",
                           "LogicalMemory24h", "VerbalFluencyTotal",
                           "SelfControl")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 5) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_cog, 
         filename = here("figures", "violin_prepost_cog.pdf"), width = 12, height = 6)


# plot pre-post CDS
violin_prepost_cds <- sway_data_long %>% 
    filter(str_detect(variable, "CDS")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 5) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_cds, 
         filename = here("figures", "violin_prepost_cds.pdf"), width = 12, height = 6)
ggsave(filename = here("figures", "violin_prepost_cds.png"),
       plot = violin_prepost_cds, width = 12, height = 6)

# plot pre-post ISI (sleep)
violin_prepost_isi <- sway_data_long %>% 
    filter(str_detect(variable, "ISI")) %>%
        ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 4) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_isi, 
         filename = here("figures", "violin_prepost_isi.pdf"), width = 12, height = 6)
ggsave(filename = here("figures", "violin_prepost_isi.png"),
       plot = violin_prepost_isi, width = 12, height = 6)

# plot pre-post PSQI (sleep)
violin_prepost_psqi <- sway_data_long %>% 
    filter(str_detect(variable, "PSQI")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 4) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_psqi, 
         filename = here("figures", "violin_prepost_psqi.pdf"), width = 12, height = 6)
ggsave(filename = here("figures", "violin_prepost_psqi.png"),
       plot = violin_prepost_psqi, width = 12, height = 6)

# plot pre-post Diary
violin_prepost_diary <- sway_data_long %>% 
    filter(str_detect(variable, "Diary")) %>%
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 4) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_diary, 
         filename = here("figures", "violin_prepost_diary.pdf"), width = 12, height = 6)
ggsave(filename = here("figures", "violin_prepost_diary.png"),
       plot = violin_prepost_diary, width = 12, height = 6)

# plot pre-post IPAQ
violin_prepost_ipaq <- sway_data_long %>% 
    filter(str_detect(variable, "IPAQ")) %>%
    mutate(variable = recode(variable, "IPAQ_MedExercise_METs" = "IPAQ_ModExercise_METs")) %>% 
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 4) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_ipaq, 
         filename = here("figures", "violin_prepost_ipaq.pdf"), width = 12, height = 6)
ggsave(filename = here("figures", "violin_prepost_ipaq.png"),
       plot = violin_prepost_ipaq, width = 12, height = 6)  

# plot pre-post MST
violin_prepost_mst <- sway_data_long %>% 
    filter(str_detect(variable, "MST")) %>%
        ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
            facet_wrap(variable ~ ., scales = "free", ncol = 4) +
            stat_compare_means(paired = TRUE, label.x = 0.75) +
            scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
            labs(x = "", y = "Measures") +
            theme(legend.position = "none")
ggexport(violin_prepost_mst, 
         filename = here("figures", "violin_prepost_mst.pdf"), width = 12, height = 10)
ggsave(filename = here("figures", "violin_prepost_mst.png"),
       plot = violin_prepost_mst, width = 12, height = 10) 

# plot pre-post RFS
violin_prepost_rfs <- sway_data_long %>% 
    filter(str_detect(variable, "RFS")) %>%
    mutate(variable = recode(variable,
                             "RFS_ExtSocial2" = "RFS_ExtSocial",
                             "RFS_ImmSocial2" = "RFS_ImmSocial",
                             "RFS_Living2" = "RFS_Living",
                             "RFS_Work2" = "RFS_Work")) %>% 
    ggviolin(x = "time", y = "value", fill = "time", add = "mean_sd") +
        facet_wrap(variable ~ ., scales = "free", ncol = 4) +
        stat_compare_means(paired = TRUE, label.x = 0.75) +
        scale_fill_manual(values = c("#FFDB6D", "#00AFBB")) +
        labs(x = "", y = "Measures") +
        theme(legend.position = "none")
ggexport(violin_prepost_rfs, 
         filename = here("figures", "violin_prepost_rfs.pdf"), width = 12, height = 6)
ggsave(filename = here("figures", "violin_prepost_rfs.png"),
       plot = violin_prepost_rfs, width = 12, height = 6)  
