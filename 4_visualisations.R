#Project: From Policy to Practice: Progress towards Data- and Code-Sharing in Ecology and Evolution
#
#Date: 2024, v0.3
#
#Author: [redacted]


# This script aims to visualize the results of the data- and code-policy review on 275 journals.

# The following code for creating a treemap was initially developed by [redacted] with guidance from 
# ChatGPT, an AI language model by OpenAI.
# Assistance provided on 2024-12-05.

# packages
library(tidyverse)
library(treemapify) #treemap
library(gridExtra)


# load data including clarity, strictness and timing of policy
data <- read.csv("FinalPolicyDeterminations_compiled.csv")
data

# Data preparation: Group and summarize by strictness, timing, and clarity
data_prepped <- data %>%
  group_by(Data_clarit_FIN, Data_strict_FIN, Data_timing_FIN) %>% 
  mutate(N_responses = 1) %>%
  mutate(Data_timing_FIN = ifelse(Data_timing_FIN=="After Acceptance (Post-Publication)", "Post-Publication", Data_timing_FIN)) %>%
  summarise(N_responses = sum(N_responses, na.rm = TRUE), .groups = "drop") %>%
  mutate(Data_strict_FIN = factor(Data_strict_FIN, levels = 
                                    c("Mandated", "Encouraged", "On Reviewer Request", "Optional for Authors", "Not Mentioned")),
         Data_clarit_FIN = ifelse(Data_clarit_FIN == "NA (no policy)", 0, Data_clarit_FIN)) 

data_prepped$label <- case_when(data_prepped$Data_clarit_FIN %in% c("0") ~ "NA", .default = data_prepped$Data_clarit_FIN)
#data_prepped$label <- paste(data_prepped$label, data_prepped$N_responses, sep = "(")
#data_prepped$label <- paste(data_prepped$label, ")", sep = "")

data_prepped$Data_timing_FIN <- case_when(data_prepped$Data_timing_FIN %in% c("Not Expected At All") ~ "Not Expected", .default = data_prepped$Data_timing_FIN)

data_prepped$Data_timing_FIN <- ordered(data_prepped$Data_timing_FIN, levels = c("Post-Publication","During Peer Review","Not Expected"))


## Treemap for data ####
p_data <- ggplot(data_prepped, aes(area = N_responses, 
                                   subgroup = Data_strict_FIN,
                                   subgroup2 = Data_timing_FIN,
                                   fill = Data_strict_FIN)) +
  geom_treemap(color = "white", size = 0.5, alpha = (as.numeric(data_prepped$Data_clarit_FIN)/5)) +
  geom_treemap_subgroup2_border(colour = "grey20", size = 1) +
  geom_treemap_subgroup_border(color = "black", size = 1.85) + 
  geom_treemap_text(
    aes(label = paste0(label)), 
    color = "black", 
    alpha = 0.75,
    size = 4.75,
    place = "bottomright",
    padding.x = grid::unit(0.7, "mm"),
    padding.y = grid::unit(1, "mm"),
    grow = FALSE) +
  geom_treemap_subgroup_text( #Strictness
    color = "black",
    alpha = 1,
    fontface = "bold",
    size = 6,
    angle = 0,
    place = "topleft") +
  geom_treemap_subgroup2_text( #Timing
    color = "black", 
    alpha = 1,  
    size = 5,
    angle = 90, 
    place = "bottomleft") +
  scale_fill_manual(values = c("Mandated" = "#229954",   
                               "Encouraged" = "#d4ac0d", 
                               "Not Mentioned" = "grey95",
                               "On Reviewer Request" =  "#d68910",
                               "Optional for Authors" = "#cb4335")) +
  labs(title = "A. Data", fill = "Strictness", alpha = "Clarity") +
  theme(panel.background = element_rect(fill = "white", color = "grey20"),
        legend.position = "none",
        plot.title = element_text(size = 8, vjust = -1))
p_data

#ggsave("outputs_visualisations/Figure1_treemap_data_RZNM.png", width = 9, height = 9, units = "cm", p_data, dpi = 600)


## Treemap for data v2 ####
p_data2 <- ggplot(data_prepped, aes(area = N_responses, 
                                   subgroup = Data_strict_FIN,
                                   subgroup2 = Data_timing_FIN,
                                   fill = Data_strict_FIN)) +
  geom_treemap(color = "white", size = 0.5, alpha = (as.numeric(data_prepped$Data_clarit_FIN)/5),
               layout = "fixed",
               start = "topleft") +
  geom_treemap_subgroup2_border(colour = "grey25", size = 1,
                                layout = "fixed",
                                start = "topleft") +
  geom_treemap_subgroup_border(color = "black", size = 1.85,
                               layout = "fixed",
                               start = "topleft") + 
  geom_treemap_text(
   aes(label = paste0(label)), 
   color = "grey35", 
   size = 5,
   place = "bottomright",
   padding.x = grid::unit(0.7, "mm"),
   padding.y = grid::unit(1, "mm"),
   grow = FALSE,
   layout = "fixed",
   start = "topleft",
   min.size = 3) +
  geom_treemap_subgroup2_text( #Timing
    color = "grey25", 
    alpha = 1,  
    size = 5,
    angle = 0, 
    place = "bottomleft",
    layout = "fixed",
    start = "topleft",
    min.size =3) +
  geom_treemap_subgroup_text( #Strictness
    color = "black",
    alpha = 1,
    fontface = "bold",
    size = 6,
    angle = 0,
    place = "topleft",
    layout = "fixed",
    start = "topleft") +
  scale_fill_manual(values = c("Mandated" = "#229954",   
                               "Encouraged" = "#d4ac0d", 
                               "Not Mentioned" = "grey95",
                               "On Reviewer Request" =  "#d68910",
                               "Optional for Authors" = "#cb4335")) +
  labs(title = "A. Data", fill = "Strictness", alpha = "Clarity") +
  theme(panel.background = element_rect(fill = "white"),
        legend.position = "none",
        plot.title = element_text(size = 8, vjust = -1))
p_data2

#ggsave("outputs_visualisations/Figure1_treemap_data_RZNMv2.png", width = 8, height = 8, units = "cm", p_data2, dpi = 600)

#ggsave("outputs_visualisations/Figure1_treemap_data_RZNMv2_nolab.png", width = 8, height = 8, units = "cm", p_data2, dpi = 600)
# additional version saved without labels to help for formatting final version. (note saved in repo)





# Code data preparation: Group and summarize by strictness, timing, and clarity
code_prepped <- data %>%
  group_by(Code_clarit_FIN, Code_strict_FIN, Code_timing_FIN) %>% 
  mutate(N_responses = 1) %>%
  mutate(Code_timing_FIN = ifelse(Code_timing_FIN=="After Acceptance (Post-Publication)", "Post-Publication", Code_timing_FIN)) %>%
  summarise(N_responses = sum(N_responses, na.rm = TRUE), .groups = "drop") %>%
  mutate(Code_strict_FIN = factor(Code_strict_FIN, levels = 
                                    c("Mandated", "Encouraged", "On Reviewer Request", "Optional for Authors", "Not Mentioned")),
         Code_clarit_FIN = ifelse(Code_clarit_FIN == "NA (no policy)", 0, Code_clarit_FIN)) 

code_prepped$label <- case_when(code_prepped$Code_clarit_FIN %in% c("0") ~ "NA", .default = code_prepped$Code_clarit_FIN)
#code_prepped$label <- paste(code_prepped$label, code_prepped$N_responses, sep = "(")
#code_prepped$label <- paste(code_prepped$label, ")", sep = "")

code_prepped$Code_timing_FIN <- case_when(code_prepped$Code_timing_FIN %in% c("Not Expected At All") ~ "Not Expected", .default = code_prepped$Code_timing_FIN)

code_prepped$Code_timing_FIN <- ordered(code_prepped$Code_timing_FIN, levels = c("Post-Publication","During Peer Review","Not Expected"))


## Treemap for code ####
p_code <- ggplot(code_prepped, aes(area = N_responses, 
                                   subgroup = Code_strict_FIN,
                                   subgroup2 = Code_timing_FIN,
                                   fill = Code_strict_FIN)) +
  geom_treemap(color = "white", size = 0.5, alpha = (as.numeric(code_prepped$Code_clarit_FIN)/5)) +
  geom_treemap_subgroup2_border(colour = "grey20", size = 1) +
  geom_treemap_subgroup_border(color = "black", size = 1.85) + 
  geom_treemap_text(
    aes(label = paste0(label)), 
    color = "black", 
    alpha = 0.75,
    size = 4.75,
    place = "bottomright",
    padding.x = grid::unit(0.7, "mm"),
    padding.y = grid::unit(1, "mm"),
    grow = FALSE) +
  geom_treemap_subgroup_text( #Strictness
    color = "black",
    alpha = 1,
    fontface = "bold",
    size = 6,
    angle = 0,
    place = "topleft") +
  geom_treemap_subgroup2_text( #Timing
    color = "black", 
    alpha = 1,  
    size = 5,
    angle = 90, 
    place = "bottomleft") +
  scale_fill_manual(values = c("Mandated" = "#229954",   
                               "Encouraged" = "#d4ac0d", 
                               "Not Mentioned" = "grey95",
                               "On Reviewer Request" =  "#d68910",
                               "Optional for Authors" = "#cb4335")) +
  labs(title = "B. Code", fill = "Strictness", alpha = "Clarity") +
  theme(panel.background = element_rect(fill = "white", color = "grey20"),
        legend.position = "none",
        plot.title = element_text(size = 6))
p_code

#ggsave("outputs_visualisations/Figure1_treemap_code_RZNM.png", width = 9, height = 9, units = "cm", p_code, dpi = 600)



## Treemap for code v2 ####
p_code2 <- ggplot(code_prepped, aes(area = N_responses, 
                                    subgroup = Code_strict_FIN,
                                    subgroup2 = Code_timing_FIN,
                                    fill = Code_strict_FIN)) +
  geom_treemap(color = "white", size = 0.5, alpha = (as.numeric(code_prepped$Code_clarit_FIN)/5),
               layout = "fixed",
               start = "topleft") +
  geom_treemap_subgroup2_border(colour = "grey25", size = 1,
                                layout = "fixed",
                                start = "topleft") +
  geom_treemap_subgroup_border(color = "black", size = 1.85,
                               layout = "fixed",
                               start = "topleft") + 
  geom_treemap_text(
    aes(label = paste0(label)), 
    color = "grey35", 
    size = 5,
    place = "bottomright",
    padding.x = grid::unit(0.7, "mm"),
    padding.y = grid::unit(1, "mm"),
    grow = FALSE,
    layout = "fixed",
    start = "topleft",
    min.size = 3) +
  geom_treemap_subgroup2_text( #Timing
    color = "grey25", 
    alpha = 1,  
    size = 5,
    angle = 0, 
    place = "bottomleft",
    layout = "fixed",
    start = "topleft",
    min.size = 4) +
  geom_treemap_subgroup_text( #Strictness
    color = "black",
    alpha = 1,
    fontface = "bold",
    size = 6,
    angle = 0,
    place = "topleft",
    layout = "fixed",
    start = "topleft") +
  scale_fill_manual(values = c("Mandated" = "#229954",   
                               "Encouraged" = "#d4ac0d", 
                               "Not Mentioned" = "grey95",
                               "On Reviewer Request" =  "#d68910",
                               "Optional for Authors" = "#cb4335")) +
  labs(title = "B. Code", fill = "Strictness", alpha = "Clarity") +
  theme(panel.background = element_rect(fill = "white"),
        legend.position = "none",
        plot.title = element_text(size = 8, vjust = -1))
p_code2

#ggsave("outputs_visualisations/Figure1_treemap_code_RZNMv2.png", width = 8, height = 8, units = "cm", p_code2, dpi = 600)



