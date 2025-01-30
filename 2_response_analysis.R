#Project: From Policy to Practice: Progress towards Data- and Code-Sharing in Ecology and Evolution
#
#Date: 2024, v0.1
#
#Author: [redacted]


#NOTE: DUE TO ANONYMISATION AND PRIVACY REQUIREMENTS FOR REVIEW, ALL DATASETS IN THIS SCRIPT CONTANING EMAIL ADDRESSES AND AUTHOR NAMES HAVE BEEN REDACTED.



#loading required packages
library(tidyverse); library(lme4); library(data.table); library(irr); library(confintr); library(rcompanion)
#library(lme4); library(rptR); library(lmerTest); library(pollster)
#Note: american journal of physical anthropology is now called the american journal of biological anthropology



#### II.A. Processing Response Data for Agreement Analyses ----
H01_respB <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_processed_others-ANON.csv")


#Finalising journal lists (initially 284): 

#5x Excluded pre-journal processing (duplicates or ceased operating)
# - bmc ecology (merged with bmc evolutionary biology to become bmc ecology and evolution)
# - bmc evolutionary biology (merged with bmc ecology to become bmc ecology and evolution)
# - evolution and development (duplicate with evolution & development)
# - nature ecology and evolution (duplicate with nature ecology & evolution)
# - natural history (original discontinued, journal of natural history still operates but is a separate journal)
H01_respB <- subset(H01_respB, MergeID != "anon_ID_825") 

#1x - Excluded as not a journal (book series)
# - advances in ecological research
H01_respB <- subset(H01_respB, Name.of.Journal != "advances in ecological research") 

#3x - Excluded as not a currently operating. 
# - american midland naturalist
# - evolutionary ecology research
# - neotropical biodiversity
H01_respB <- subset(H01_respB, !(Name.of.Journal %in% c("american midland naturalist", "evolutionary ecology research", "neotropical biodiversity")))

#renaming two journals to their current name
H01_respB$Name.of.Journal <- case_when(
  H01_respB$Name.of.Journal %in% c("plankton biology and ecology ( \"plankton biology and ecology\" has changed name to \"plankton and benthos research\" in 2006)") ~ "plankton and benthos research",
  H01_respB$Name.of.Journal %in% c("american journal of physical anthropology") ~ "american journal of biological anthropology",
  .default = H01_respB$Name.of.Journal
)

#Journals and number of responses
journal_list <- NULL
journal_list <- as.data.frame(table(H01_respB$Name.of.Journal))
colnames(journal_list) <- c("Journals", "N_responses")
nrow(journal_list) #275 journals
sum(journal_list$N_responses) #825 responses

#write.csv(journal_list[,1], "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_S1_journal_list.csv")



#Timing rating (data)
#table(H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided..x)
H01_respB_dat_timing <- table(H01_respB$Name.of.Journal, H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided..x)
H01_respB_dat_timing <- as.data.frame(H01_respB_dat_timing)

H01_respB_dat_timing_red <- subset(H01_respB_dat_timing, Freq >= 2)
colnames(H01_respB_dat_timing_red) <- c("Journals", "Data_timing", "Data_timing_agree")

H01_respB_aggregated <- merge(journal_list, H01_respB_dat_timing_red, by = "Journals", all.x= TRUE)



#Strictness rating (data)
#table(H01_respB$How.strict.is.this.policy...Data.policy.)
H01_respB_dat_strict <- table(H01_respB$Name.of.Journal, H01_respB$How.strict.is.this.policy...Data.policy.)
H01_respB_dat_strict <- as.data.frame(H01_respB_dat_strict)

H01_respB_dat_strict_red <- subset(H01_respB_dat_strict, Freq >= 2)
colnames(H01_respB_dat_strict_red) <- c("Journals", "Data_strict", "Data_strict_agree")

H01_respB_aggregated <- merge(H01_respB_aggregated, H01_respB_dat_strict_red, by = "Journals", all.x= TRUE)



#Clarity Scores (data)

# - calculating the mean score, excluding NAs (i.e., no responses)
H01_respB_dat_clarit1 <- setDT(subset(H01_respB, How.clear.do.you.think.this.statement.is. != 'NA'))[ , list(Data_clar_mean = mean(How.clear.do.you.think.this.statement.is.)),
                                            by = .(Name.of.Journal)]
colnames(H01_respB_dat_clarit1) <- c("Journals", "Data_clar_mean")


# - calculating the mode score, including No_Rating as an independent class
H01_respB$How.clear.do.you.think.this.statement.is. <- as.character(H01_respB$How.clear.do.you.think.this.statement.is.)

H01_respB$How.clear.do.you.think.this.statement.is. <- case_when(
  H01_respB$How.clear.do.you.think.this.statement.is. %in% c("NA", NA) ~ "No_Rating",
  .default = H01_respB$How.clear.do.you.think.this.statement.is.
)

H01_respB_dat_clarit2 <- table(H01_respB$Name.of.Journal, H01_respB$How.clear.do.you.think.this.statement.is.)
H01_respB_dat_clarit2 <- as.data.frame(H01_respB_dat_clarit2)
H01_respB_dat_clarit2_red <- subset(H01_respB_dat_clarit2, Freq >= 2)
colnames(H01_respB_dat_clarit2_red) <- c("Journals", "Data_clar_mode", "Data_clar_agree")
#nrow(H01_respB_dat_clarit2_red)

H01_respB_dat_clarit <- merge(H01_respB_dat_clarit1, H01_respB_dat_clarit2_red, by = "Journals", all.x = TRUE)


#Calculating the number of NAs
H01_respB_dat_clarit_N <- as.data.frame(table(subset(H01_respB, How.clear.do.you.think.this.statement.is. != 'No_Rating')$Name.of.Journal))
colnames(H01_respB_dat_clarit_N) <- c("Journals", "Data_clar_NAs")
H01_respB_dat_clarit <- merge(H01_respB_dat_clarit, H01_respB_dat_clarit_N, by = "Journals", all.x= TRUE)
H01_respB_aggregated <- merge(H01_respB_aggregated, H01_respB_dat_clarit, by = "Journals", all.x= TRUE)

H01_respB_aggregated$Data_clar_NAs <- H01_respB_aggregated$N_responses - H01_respB_aggregated$Data_clar_NAs

H01_respB_aggregated$Data_clar_NAs <- case_when(
  H01_respB_aggregated$Data_clar_NAs %in% c("NA", NA) ~ 0,
  .default = H01_respB_aggregated$Data_clar_NAs
)




#Processing timing rating (code)
#table(H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided..x)

H01_respB_cod_timing <- table(H01_respB$Name.of.Journal, H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided..x)
H01_respB_cod_timing <- as.data.frame(H01_respB_cod_timing)

H01_respB_cod_timing_red <- subset(H01_respB_cod_timing, Freq >= 2)
colnames(H01_respB_cod_timing_red) <- c("Journals", "Code_timing", "Code_timing_agree")

H01_respB_aggregated <- merge(H01_respB_aggregated, H01_respB_cod_timing_red, by = "Journals", all.x= TRUE)



#Processing strictness rating (code)
#table(H01_respB$How.strict.is.this.policy...Code.Policy.)

H01_respB_cod_strict <- table(H01_respB$Name.of.Journal, H01_respB$How.strict.is.this.policy...Code.Policy.)
H01_respB_cod_strict <- as.data.frame(H01_respB_cod_strict)

H01_respB_cod_strict_red <- subset(H01_respB_cod_strict, Freq >= 2)
colnames(H01_respB_cod_strict_red) <-  c("Journals", "Code_strict", "Code_strict_agree")

H01_respB_aggregated <- merge(H01_respB_aggregated, H01_respB_cod_strict_red, by = "Journals", all.x= TRUE)


labels(H01_respB_aggregated)


#Clarity Scores (code)

# - calculating the mean score, excluding NAs (i.e., no responses)
H01_respB_cod_clarit1 <- setDT(subset(H01_respB, How.clear.do.you.think.this.statement.is..1 != 'NA'))[ , list(Code_clar_mean = mean(How.clear.do.you.think.this.statement.is..1)),
                                                                                                      by = .(Name.of.Journal)]
colnames(H01_respB_cod_clarit1) <- c("Journals", "Code_clar_mean")


# - calculating the mode score, including No_Rating as an independent class
H01_respB$How.clear.do.you.think.this.statement.is..1 <- as.character(H01_respB$How.clear.do.you.think.this.statement.is..1)

H01_respB$How.clear.do.you.think.this.statement.is..1 <- case_when(
  H01_respB$How.clear.do.you.think.this.statement.is..1 %in% c("NA", NA) ~ "No_Rating",
  .default = H01_respB$How.clear.do.you.think.this.statement.is..1
)

H01_respB_cod_clarit2 <- table(H01_respB$Name.of.Journal, H01_respB$How.clear.do.you.think.this.statement.is..1)
H01_respB_cod_clarit2 <- as.data.frame(H01_respB_cod_clarit2)
H01_respB_cod_clarit2_red <- subset(H01_respB_cod_clarit2, Freq >= 2)
colnames(H01_respB_cod_clarit2_red) <- c("Journals", "Code_clar_mode", "Code_clar_agree")
#nrow(H01_respB_cod_clarit2_red)

H01_respB_cod_clarit <- merge(H01_respB_cod_clarit1, H01_respB_cod_clarit2_red, by = "Journals", all.x = TRUE)


#Calculating the number of NAs
H01_respB_cod_clarit_N <- as.data.frame(table(subset(H01_respB, How.clear.do.you.think.this.statement.is..1 != 'No_Rating')$Name.of.Journal))
colnames(H01_respB_cod_clarit_N) <- c("Journals", "Code_clar_NAs")
H01_respB_cod_clarit <- merge(H01_respB_cod_clarit, H01_respB_cod_clarit_N, by = "Journals", all.x= TRUE)
H01_respB_aggregated <- merge(H01_respB_aggregated, H01_respB_cod_clarit, by = "Journals", all.x= TRUE)

H01_respB_aggregated$Code_clar_NAs <- H01_respB_aggregated$N_responses - H01_respB_aggregated$Code_clar_NAs

H01_respB_aggregated$Code_clar_NAs <- case_when(
  H01_respB_aggregated$Code_clar_NAs %in% c("NA", NA) ~ 0,
  .default = H01_respB_aggregated$Code_clar_NAs
)


#write.csv(H01_respB_aggregated, "~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_aggregated.csv", row.names = FALSE) #superceded version
# - superseded version includes 3x journals now excluded

#write.csv(H01_respB_aggregated, "~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_aggregated_01102024.csv", row.names = FALSE) #final version




#### II.B. Agreement levels (initial summary dat, Strictness + Timing + Clarity) ----

H01_respB_aggregated <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_aggregated_01102024.csv")


H01_respB_aggregated$Data_timing_agree <- as.character(H01_respB_aggregated$Data_timing_agree)
H01_respB_aggregated$Data_timing_agree <- case_when(
  H01_respB_aggregated$Data_timing_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated$Data_timing_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated$Data_timing_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated$Data_timing_agree
)

dat_agree1 <- as.data.frame(table(H01_respB_aggregated$Data_timing_agree))



H01_respB_aggregated$Data_strict_agree <- as.character(H01_respB_aggregated$Data_strict_agree)
H01_respB_aggregated$Data_strict_agree <- case_when(
  H01_respB_aggregated$Data_strict_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated$Data_strict_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated$Data_strict_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated$Data_strict_agree
)

dat_agree2 <- as.data.frame(table(H01_respB_aggregated$Data_strict_agree))



H01_respB_aggregated$Data_clar_agree <- as.character(H01_respB_aggregated$Data_clar_agree)
H01_respB_aggregated$Data_clar_agree <- case_when(
  H01_respB_aggregated$Data_clar_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated$Data_clar_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated$Data_clar_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated$Data_clar_agree
)

dat_agree3 <- as.data.frame(table(H01_respB_aggregated$Data_clar_agree))



H01_respB_aggregated$Code_timing_agree <- as.character(H01_respB_aggregated$Code_timing_agree)
H01_respB_aggregated$Code_timing_agree <- case_when(
  H01_respB_aggregated$Code_timing_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated$Code_timing_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated$Code_timing_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated$Code_timing_agree
)

dat_agree4 <- as.data.frame(table(H01_respB_aggregated$Code_timing_agree))



H01_respB_aggregated$Code_strict_agree <- as.character(H01_respB_aggregated$Code_strict_agree)
H01_respB_aggregated$Code_strict_agree <- case_when(
  H01_respB_aggregated$Code_strict_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated$Code_strict_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated$Code_strict_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated$Code_strict_agree
)

dat_agree5 <- as.data.frame(table(H01_respB_aggregated$Code_strict_agree))



H01_respB_aggregated$Code_clar_agree <- as.character(H01_respB_aggregated$Code_clar_agree)
H01_respB_aggregated$Code_clar_agree <- case_when(
  H01_respB_aggregated$Code_clar_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated$Code_clar_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated$Code_clar_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated$Code_clar_agree
)

dat_agree6 <- as.data.frame(table(H01_respB_aggregated$Code_clar_agree))



dat_agree <- merge(dat_agree1, dat_agree2, by = 'Var1', allx = TRUE)
dat_agree <- merge(dat_agree, dat_agree3, by = 'Var1', allx = TRUE)
dat_agree <- merge(dat_agree, dat_agree4, by = 'Var1', allx = TRUE)
dat_agree <- merge(dat_agree, dat_agree5, by = 'Var1', allx = TRUE)
dat_agree <- merge(dat_agree, dat_agree6, by = 'Var1', allx = TRUE)

colnames(dat_agree) <- c("Agreement","Data_timing", "Data_strict",  "Data_clar", 
                         "Code_timing", "Code_strict", "Code_clar")

dat_agree <- dat_agree[c(1,3,2),]


sum(dat_agree$Data_timing)
sum(dat_agree$Data_strict)
sum(dat_agree$Code_timing)
sum(dat_agree$Code_strict)
sum(dat_agree$Data_clar)
sum(dat_agree$Code_clar)


#write.csv(dat_agree,  "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Agreement_qual.csv", row.names = FALSE)
#(initial qualitative assessment of agreement levels, superceded by Table_DEresp1 & Table_DEresp1_clar. Not included in the final repository)


#### II.C. Agreement levels (fleiss-kappa; Strictness + Timing) ----

table(H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided..x)
table(H01_respB$How.strict.is.this.policy...Data.policy.)
table(H01_respB$How.clear.do.you.think.this.statement.is.)
table(H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided..x)
table(H01_respB$How.strict.is.this.policy...Code.Policy.)
table(H01_respB$How.clear.do.you.think.this.statement.is..1)


#Note these cannot handle with NAs, but are not reliant on reviewer ID 
set.seed(12)

# - randomly sampling to create data frame for agreement analysis
Resp1 <- H01_respB %>%
  group_by(Name.of.Journal) %>%
  sample_n(1)

H01_respB_working <- subset(H01_respB, !(MergeID %in% Resp1$MergeID))

Resp2 <- H01_respB_working %>%
  group_by(Name.of.Journal) %>%
  sample_n(1)

H01_respB_working <- subset(H01_respB_working, !(MergeID %in% Resp2$MergeID))

Resp3 <- H01_respB_working %>%
  group_by(Name.of.Journal) %>%
  sample_n(1)

intersect(Resp1$MergeID, Resp2$MergeID)
intersect(Resp2$MergeID, Resp3$MergeID)
intersect(Resp3$MergeID, Resp1$MergeID)

nrow(as.data.frame(setdiff(Resp1$MergeID, Resp2$MergeID)))
nrow(as.data.frame(setdiff(Resp2$MergeID, Resp3$MergeID)))
nrow(as.data.frame(setdiff(Resp3$MergeID, Resp1$MergeID)))


# - data ICCs
Resp_dat_time <- NULL
Resp_dat_time$rev1 <- Resp1$When.was.the.earliest.the.journal.expected.data.to.be.provided..x
Resp_dat_time$rev2 <- Resp2$When.was.the.earliest.the.journal.expected.data.to.be.provided..x
Resp_dat_time$rev3 <- Resp3$When.was.the.earliest.the.journal.expected.data.to.be.provided..x
Resp_dat_time <- as.data.frame(Resp_dat_time)

KapFle_data_time <- kappam.fleiss(Resp_dat_time, exact = FALSE, detail = FALSE)
KapFle_data_time



Resp_dat_stri <- NULL
Resp_dat_stri$rev1 <- Resp1$How.strict.is.this.policy...Data.policy.
Resp_dat_stri$rev2 <- Resp2$How.strict.is.this.policy...Data.policy.
Resp_dat_stri$rev3 <- Resp3$How.strict.is.this.policy...Data.policy.
Resp_dat_stri <- as.data.frame(Resp_dat_stri)

KapFle_data_stri <- kappam.fleiss(Resp_dat_stri, exact = FALSE, detail = FALSE)
KapFle_data_stri



# - code ICCs
Resp_cod_time <- NULL
Resp_cod_time$rev1 <- Resp1$When.was.the.earliest.the.journal.expected.code.to.be.provided..x
Resp_cod_time$rev2 <- Resp2$When.was.the.earliest.the.journal.expected.code.to.be.provided..x
Resp_cod_time$rev3 <- Resp3$When.was.the.earliest.the.journal.expected.code.to.be.provided..x
Resp_cod_time <- as.data.frame(Resp_cod_time)

KapFle_code_time <- kappam.fleiss(Resp_cod_time, exact = FALSE, detail = FALSE)
KapFle_code_time



Resp_cod_stri <- NULL
Resp_cod_stri$rev1 <- Resp1$How.strict.is.this.policy...Code.Policy.
Resp_cod_stri$rev2 <- Resp2$How.strict.is.this.policy...Code.Policy.
Resp_cod_stri$rev3 <- Resp3$How.strict.is.this.policy...Code.Policy.
Resp_cod_stri <- as.data.frame(Resp_cod_stri)

KapFle_code_stri <- kappam.fleiss(Resp_cod_stri, exact = FALSE, detail = FALSE)
KapFle_code_stri



#Make look nice
rownames(dat_agree) <- dat_agree$Agreement
dat_agree
dat_agree_tp <- transpose(dat_agree)
rownames(dat_agree_tp) <- colnames(dat_agree)
colnames(dat_agree_tp) <- rownames(dat_agree)
dat_agree_tp <- dat_agree_tp[-1,]
dat_agree_tp$`Full (3/3)` <- as.numeric(dat_agree_tp$`Full (3/3)`)
dat_agree_tp$`Partial (2/3)` <- as.numeric(dat_agree_tp$`Partial (2/3)`)
dat_agree_tp$`None` <- as.numeric(dat_agree_tp$`None`)

dat_agree_tp_timestri <- dat_agree_tp[c(-3,-6),]
dat_agree_tp_timestri$Fleiss_kappa <- format(round(c(KapFle_data_time$value, KapFle_data_stri$value, 
                                        KapFle_code_time$value, KapFle_code_stri$value), digits = 3), n_small = 3)
dat_agree_tp_timestri$Fleiss_kappa <- paste(dat_agree_tp_timestri$Fleiss_kappa, "(P < 0.001)", sep = )

dat_agree_tp_timestri$`Full (3/3)` <- paste(dat_agree_tp_timestri$`Full (3/3)`, format(round(100*(dat_agree_tp_timestri$`Full (3/3)`/275), digits = 2), n_small = 2), sep = " (")
dat_agree_tp_timestri$`Full (3/3)` <- paste(dat_agree_tp_timestri$`Full (3/3)`, "", sep = "%)")
dat_agree_tp_timestri$`Partial (2/3)` <- paste(dat_agree_tp_timestri$`Partial (2/3)`, format(round(100*(dat_agree_tp_timestri$`Partial (2/3)`/275), digits = 2), n_small = 2), sep = " (")
dat_agree_tp_timestri$`Partial (2/3)` <- paste(dat_agree_tp_timestri$`Partial (2/3)`, "", sep = "%)")
dat_agree_tp_timestri$None <- paste(dat_agree_tp_timestri$None, format(round(100*(dat_agree_tp_timestri$None/275), digits = 2), n_small = 2), sep = " (")
dat_agree_tp_timestri$None <- paste(dat_agree_tp_timestri$None, "", sep = "%)")

knitr::kable(dat_agree_tp_timestri, "simple", align = "lcccc", row.names = TRUE)

#write.csv(dat_agree_tp_timestri, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_DEresp1.csv", row.names = FALSE)



#### II.D. Preparing spreadsheet to review disagreements/unclear ----
# obsolete 

#H01_respB_review <- NULL
#H01_respB_review$Journals <- H01_respB_aggregated$Journals
#H01_respB_review <- as.data.frame(H01_respB_review)
#H01_respB_review$Reviewer_A <- ""
#H01_respB_review$Reviewer_B <- ""
#H01_respB_review$Reviewer_notes <- ""
#H01_respB_review$Data_timing_DE <- H01_respB_aggregated$Data_timing
#H01_respB_review$Data_timing_agree <- H01_respB_aggregated$Data_timing_agree
#H01_respB_review$Data_timing_FIN <- H01_respB_aggregated$Data_timing
#
#H01_respB_review$Data_timing_FIN <- case_when(
#  H01_respB_review$Data_timing_FIN %in% c("Unclear") ~ "",
#  H01_respB_review$Data_timing_agree %in% c("None", "Partial (2/3)") ~ "",
#  .default = H01_respB_review$Data_timing_FIN
#)
#
#
#H01_respB_review$Data_strict_DE <- H01_respB_aggregated$Data_strict
#H01_respB_review$Data_strict_agree <- H01_respB_aggregated$Data_strict_agree
#H01_respB_review$Data_strict_FIN <- H01_respB_aggregated$Data_strict
#
#H01_respB_review$Data_strict_FIN <- case_when(
#  H01_respB_review$Data_strict_FIN %in% c("Unclear") ~ "",
#  H01_respB_review$Data_strict_agree %in% c("None", "Partial (2/3)") ~ "",
#  .default = H01_respB_review$Data_strict_FIN
#)
#
#
#H01_respB_review$Code_timing_DE <- H01_respB_aggregated$Code_timing
#H01_respB_review$Code_timing_agree <- H01_respB_aggregated$Code_timing_agree
#H01_respB_review$Code_timing_FIN <- H01_respB_aggregated$Code_timing
#
#H01_respB_review$Code_timing_FIN <- case_when(
#  H01_respB_review$Code_timing_FIN %in% c("Unclear") ~ "",
#  H01_respB_review$Code_timing_agree %in% c("None", "Partial (2/3)") ~ "",
#  .default = H01_respB_review$Code_timing_FIN
#)
#
#
#H01_respB_review$Code_strict_DE <- H01_respB_aggregated$Code_strict
#H01_respB_review$Code_strict_agree <- H01_respB_aggregated$Code_strict_agree
#H01_respB_review$Code_strict_FIN <- H01_respB_aggregated$Code_strict
#
#H01_respB_review$Code_strict_FIN <- case_when(
#  H01_respB_review$Code_strict_FIN %in% c("Unclear") ~ "",
#  H01_respB_review$Code_strict_agree %in% c("None", "Partial (2/3)") ~ "",
#  .default = H01_respB_review$Code_strict_FIN
#)
#
#
#table(H01_respB_review$Data_timing_FIN)
#table(H01_respB_review$Data_strict_FIN)
#table(H01_respB_review$Code_timing_FIN)
#table(H01_respB_review$Code_strict_FIN)


#write.csv(H01_respB_review, "~/OpenDataCode_Analysis_OSF/data_responses/processing_disagreements/H01_respB_processing_disgreements.csv", row.names = FALSE)
#note: 3 journals were not excluded from this version, but have now been excluded from analysis prior to this point. 



#### II.E. Agreement levels (kendall; Clarity) ----
#Note, this likes data as numeric, ordering does not work.  

#Note, final agreements clarity ratings are not resolved for in the same way.

#Steps: 
# - For studies with a Data_strict_FIN == 'Not Mentioned', Data_clar_FIN <- "NA" (based on the H01_respB_review)
# - For studies with Data_strict_FIN != 'Not Mentioned'  How.clear.do.you.think.this.statement.is..1 == 'No_Rating' <- 1
#    - The reasoning is that if this was left blank, this was usually because they could not find any policy and/or decided the policy did not exist.
#    - Therefore, in cases where a policy existed & How.clear.do.you.think.this.statement.is..1 == 'No_Rating', 'No_Rating' can be treated as ~ 1 (Totally Unclear). 

# Agreement levels for only the subset of journal where a policy exists can be assessed,
# Aggregated clarity scores (e.g., derived from either the mode or mean of responses can then be used to calculate the clarity score)


FinalDetdat <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/processing_disagreements/H01_FinalDeterms_01102024-ANON.csv")
FinalDetdat <- FinalDetdat[,-c(8,9,11,12,14,15,17,18)]
FinalDetdat <- subset(FinalDetdat, !(Journals %in% c("american midland naturalist", "evolutionary ecology research", "neotropical biodiversity")))
nrow(FinalDetdat)

#setdiff(FinalDetdat$Journals, H01_respB$Name.of.Journal)
#setdiff(H01_respB$Name.of.Journal, FinalDetdat$Journals)
intersect(FinalDetdat$Journals, H01_respB$Name.of.Journal)


#excluding journals with no data policy at all from clarity ratings
table(FinalDetdat$Data_strict_FIN) #29 with data not mentioned
H01_respB_aggregated_datclar <- subset(H01_respB_aggregated, !(Journals %in% subset(FinalDetdat, Data_strict_FIN == "Not Mentioned")$Journal))
#nrow(H01_respB_aggregated_datclar)


# Re-calculating data agreement scores based on reduced list. 
H01_respB_datclar <- subset(H01_respB, Name.of.Journal %in% c(H01_respB_aggregated_datclar$Journals))
nrow(H01_respB_datclar)/3

H01_respB_datclar$How.clear.do.you.think.this.statement.is. <- case_when(
  H01_respB_datclar$How.clear.do.you.think.this.statement.is. %in% c("1", "No_Rating") ~ "1",
  .default = H01_respB_datclar$How.clear.do.you.think.this.statement.is.
)

H01_respB_dat_clarit_fin <- table(H01_respB_datclar$Name.of.Journal, H01_respB_datclar$How.clear.do.you.think.this.statement.is.)
H01_respB_dat_clarit_fin <- as.data.frame(H01_respB_dat_clarit_fin)
H01_respB_dat_clarit_fin_red <- subset(H01_respB_dat_clarit_fin, Freq >= 2)
colnames(H01_respB_dat_clarit_fin_red) <- c("Journals", "Data_clar_mode", "Data_clar_agree")

H01_respB_aggregated_datclar_red <- merge(H01_respB_aggregated_datclar, H01_respB_dat_clarit_fin_red, by = "Journals", all.x = TRUE)
colnames(H01_respB_aggregated_datclar_red)


H01_respB_aggregated_datclar_red$Data_clar_agree <- as.character(H01_respB_aggregated_datclar_red$Data_clar_agree.y)
H01_respB_aggregated_datclar_red$Data_clar_agree <- case_when(
  H01_respB_aggregated_datclar_red$Data_clar_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated_datclar_red$Data_clar_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated_datclar_red$Data_clar_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated_datclar_red$Data_clar_agree
)

dat_agree7 <- as.data.frame(table(H01_respB_aggregated_datclar_red$Data_clar_agree))



#excluding journals with no code policy at all from clarity ratings
table(FinalDetdat$Code_strict_FIN) #64 with code not mentioned
H01_respB_aggregated_codclar <- subset(H01_respB_aggregated, !(Journals %in% subset(FinalDetdat, Code_strict_FIN == "Not Mentioned")$Journal))
#nrow(H01_respB_aggregated_codclar)


# Re-calculating code agreement scores based on reduced list. 
H01_respB_codclar <- subset(H01_respB, Name.of.Journal %in% c(H01_respB_aggregated_codclar$Journals))
nrow(H01_respB_codclar)/3

H01_respB_codclar$How.clear.do.you.think.this.statement.is..1 <- case_when(
  H01_respB_codclar$How.clear.do.you.think.this.statement.is..1 %in% c("1", "No_Rating") ~ "1",
  .default = H01_respB_codclar$How.clear.do.you.think.this.statement.is..1
)

H01_respB_cod_clarit_fin <- table(H01_respB_codclar$Name.of.Journal, H01_respB_codclar$How.clear.do.you.think.this.statement.is..1)
H01_respB_cod_clarit_fin <- as.data.frame(H01_respB_cod_clarit_fin)
H01_respB_cod_clarit_fin_red <- subset(H01_respB_cod_clarit_fin, Freq >= 2)
colnames(H01_respB_cod_clarit_fin_red) <- c("Journals", "Code_clar_mode", "Code_clar_agree")

H01_respB_aggregated_codclar_red <- merge(H01_respB_aggregated_codclar, H01_respB_cod_clarit_fin_red, by = "Journals", all.x = TRUE)
colnames(H01_respB_aggregated_codclar_red)


H01_respB_aggregated_codclar_red$Code_clar_agree <- as.character(H01_respB_aggregated_codclar_red$Code_clar_agree.y)
H01_respB_aggregated_codclar_red$Code_clar_agree <- case_when(
  H01_respB_aggregated_codclar_red$Code_clar_agree %in% c("NA", NA) ~ "None",
  H01_respB_aggregated_codclar_red$Code_clar_agree %in% c("2") ~ "Partial (2/3)",
  H01_respB_aggregated_codclar_red$Code_clar_agree %in% c("3") ~ "Full (3/3)",
  .default = H01_respB_aggregated_codclar_red$Code_clar_agree
)

dat_agree8 <- as.data.frame(table(H01_respB_aggregated_codclar_red$Code_clar_agree))



#formatting for data agreement analysis
Resp1_reddat <- subset(Resp1, Name.of.Journal %in% H01_respB_aggregated_datclar$Journals)
Resp2_reddat <- subset(Resp2, Name.of.Journal %in% H01_respB_aggregated_datclar$Journals)
Resp3_reddat <- subset(Resp3, Name.of.Journal %in% H01_respB_aggregated_datclar$Journals)

Resp1_reddat$How.clear.do.you.think.this.statement.is. <- case_when(
  Resp1_reddat$How.clear.do.you.think.this.statement.is. %in% c("1", "No_Rating") ~ "1",
  .default = Resp1_reddat$How.clear.do.you.think.this.statement.is.
)
Resp2_reddat$How.clear.do.you.think.this.statement.is. <- case_when(
  Resp2_reddat$How.clear.do.you.think.this.statement.is. %in% c("1", "No_Rating") ~ "1",
  .default = Resp2_reddat$How.clear.do.you.think.this.statement.is.
)
Resp3_reddat$How.clear.do.you.think.this.statement.is. <- case_when(
  Resp3_reddat$How.clear.do.you.think.this.statement.is. %in% c("1", "No_Rating") ~ "1",
  .default = Resp3_reddat$How.clear.do.you.think.this.statement.is.
)



#calculating scores
Resp_dat_clar <- NULL
Resp_dat_clar$rev1 <- Resp1_reddat$How.clear.do.you.think.this.statement.is.
Resp_dat_clar$rev2 <- Resp2_reddat$How.clear.do.you.think.this.statement.is.
Resp_dat_clar$rev3 <- Resp3_reddat$How.clear.do.you.think.this.statement.is.
Resp_dat_clar <- as.data.frame(Resp_dat_clar)

Resp_dat_clar$rev1 <- ordered(Resp_dat_clar$rev1, levels = c("1", "2", "3", "4", "5"))
Resp_dat_clar$rev2 <- ordered(Resp_dat_clar$rev2, levels = c("1", "2", "3", "4", "5"))
Resp_dat_clar$rev3 <- ordered(Resp_dat_clar$rev3, levels = c("1", "2", "3", "4", "5"))
levels(Resp_dat_clar$rev1)

rownames(Resp_dat_clar) <- Resp3_reddat$Name.of.Journal #in case we need to calculate averages later

Kendal_data_clar <- kendall(Resp_dat_clar, correct = FALSE)
Kendal_data_clar




#formatting for code agreement analysis
Resp1_reddat2 <- subset(Resp1, Name.of.Journal %in% H01_respB_aggregated_codclar$Journals)
Resp2_reddat2 <- subset(Resp2, Name.of.Journal %in% H01_respB_aggregated_codclar$Journals)
Resp3_reddat2 <- subset(Resp3, Name.of.Journal %in% H01_respB_aggregated_codclar$Journals)

Resp1_reddat2$How.clear.do.you.think.this.statement.is..1 <- case_when(
  Resp1_reddat2$How.clear.do.you.think.this.statement.is..1 %in% c("1", "No_Rating") ~ "1",
  .default = Resp1_reddat2$How.clear.do.you.think.this.statement.is..1
)
Resp2_reddat2$How.clear.do.you.think.this.statement.is..1 <- case_when(
  Resp2_reddat2$How.clear.do.you.think.this.statement.is..1 %in% c("1", "No_Rating") ~ "1",
  .default = Resp2_reddat2$How.clear.do.you.think.this.statement.is..1
)
Resp3_reddat2$How.clear.do.you.think.this.statement.is..1 <- case_when(
  Resp3_reddat2$How.clear.do.you.think.this.statement.is..1 %in% c("1", "No_Rating") ~ "1",
  .default = Resp3_reddat2$How.clear.do.you.think.this.statement.is..1
)

Resp_cod_clar <- NULL
Resp_cod_clar$rev1 <- Resp1_reddat2$How.clear.do.you.think.this.statement.is..1
Resp_cod_clar$rev2 <- Resp2_reddat2$How.clear.do.you.think.this.statement.is..1
Resp_cod_clar$rev3 <- Resp3_reddat2$How.clear.do.you.think.this.statement.is..1
Resp_cod_clar <- as.data.frame(Resp_cod_clar)

Resp_cod_clar$rev1 <- ordered(Resp_cod_clar$rev1, levels = c("1", "2", "3", "4", "5"))
Resp_cod_clar$rev2 <- ordered(Resp_cod_clar$rev2, levels = c("1", "2", "3", "4", "5"))
Resp_cod_clar$rev3 <- ordered(Resp_cod_clar$rev3, levels = c("1", "2", "3", "4", "5"))
levels(Resp_cod_clar$rev1)

rownames(Resp_cod_clar) <- Resp3_reddat2$Name.of.Journal #in case we need to calculate averages later

Kendal_code_clar <- kendall(Resp_cod_clar, correct = FALSE)
Kendal_code_clar



#Make look nice
dat_agree_cla <- cbind(dat_agree7,dat_agree8)
row.names(dat_agree_cla) <- dat_agree_cla$Var1
dat_agree_cla <- dat_agree_cla[c(1,3,2),-c(1,3)]
colnames(dat_agree_cla) <- c("Data_clar", "Code_clar")

#Make look nice
rownames(dat_agree_cla) <- dat_agree$Agreement
dat_agree_cla
dat_agree_cla_tp <- transpose(dat_agree_cla)
rownames(dat_agree_cla_tp) <- colnames(dat_agree_cla)
colnames(dat_agree_cla_tp) <- rownames(dat_agree_cla)
dat_agree_cla_tp$`Full (3/3)` <- as.numeric(dat_agree_cla_tp$`Full (3/3)`)
dat_agree_cla_tp$`Partial (2/3)` <- as.numeric(dat_agree_cla_tp$`Partial (2/3)`)
dat_agree_cla_tp$`None` <- as.numeric(dat_agree_cla_tp$`None`)

dat_agree_cla_tp$Kendall<- format(round(c(Kendal_data_clar$value, Kendal_code_clar$value), digits = 3), n_small = 3)
dat_agree_cla_tp$Kendall <- paste(dat_agree_cla_tp$Kendall, "(P < 0.001)", sep = " ")

dat_agree_cla_tp$N_tot <- c(246, 211)
dat_agree_cla_tp$`Full (3/3)` <- paste(dat_agree_cla_tp$`Full (3/3)`, format(round(100*(dat_agree_cla_tp$`Full (3/3)`/dat_agree_cla_tp$N_tot), digits = 2), n_small = 2), sep = " (")
dat_agree_cla_tp$`Full (3/3)` <- paste(dat_agree_cla_tp$`Full (3/3)`, "", sep = "%)")
dat_agree_cla_tp$`Partial (2/3)` <- paste(dat_agree_cla_tp$`Partial (2/3)`, format(round(100*(dat_agree_cla_tp$`Partial (2/3)`/dat_agree_cla_tp$N_tot), digits = 2), n_small = 2), sep = " (")
dat_agree_cla_tp$`Partial (2/3)` <- paste(dat_agree_cla_tp$`Partial (2/3)`, "", sep = "%)")
dat_agree_cla_tp$None <- paste(dat_agree_cla_tp$None, format(round(100*(dat_agree_cla_tp$None/dat_agree_cla_tp$N_tot), digits = 2), n_small = 2), sep = " (")
dat_agree_cla_tp$None <- paste(dat_agree_cla_tp$None, "", sep = "%)")

dat_agree_cla_tp <- dat_agree_cla_tp[,-5] 

knitr::kable(dat_agree_cla_tp, "simple", align = "lcccc", row.names = TRUE)

#write.csv(dat_agree_cla_tp, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_DEresp1_clar.csv", row.names = TRUE)



#### II.F. Summary data ---- 
#EIC: It has the 96 journals from Culina (although we’re missing the North American Benthological Society from ours…). 
#     - In this case we wrote that we’d compare the number that encourage or mandate, I’m not sure what to do with the encourage/mandate ones – I’m inclined to simply use those that are mandated or encouraged.
#     It has 199 journals from Roche – but not sure how much they overlap. they score there policies as none = no data policy found, weak = recommend data archiving, strong = mandatory data archiving. In this case, strong would mean mandated and weak would equal encourage/optional.


#Summary Data: 
FinalDetdat$Data_strict_FIN <- ordered(FinalDetdat$Data_strict_FIN, levels = c("Mandated", "Encouraged", "On Reviewer Request", 
                                                                               "Optional for Authors", "Not Mentioned"))
FinalDetdat$Data_timing_FIN <- ordered(FinalDetdat$Data_timing_FIN, levels = c("During Peer Review", "After Acceptance (Post-Publication)", 
                                                                               "Not Expected At All"))

table_summdat <- as.data.frame(table(FinalDetdat$Data_timing_FIN, FinalDetdat$Data_strict_FIN))
table_summdat <- table_summdat[-c(3,6,9,13,14),c(2,1,3)] 
table_summdat$Perc <- format(round((100*table_summdat$Freq/275), digits = 2), n_small = 2)

table_summdat$Freq <- paste(table_summdat$Freq, table_summdat$Perc, sep = " (")
table_summdat$Freq <- paste(table_summdat$Freq, "%)", sep = "")
table_summdat <- table_summdat[,-4]

colnames(table_summdat) <- c("Strictness of the policy", "When is data expected to be shared?", "Data policy (# journals)")
#write.csv(table_summdat, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_FinDet1.csv", row.names = FALSE)


FinalDetdat$Code_strict_FIN <- ordered(FinalDetdat$Code_strict_FIN, levels = c("Mandated", "Encouraged", "On Reviewer Request", 
                                                                               "Optional for Authors", "Not Mentioned"))
FinalDetdat$Code_timing_FIN <- ordered(FinalDetdat$Code_timing_FIN, levels = c("During Peer Review", "After Acceptance (Post-Publication)", 
                                                                               "Not Expected At All"))

table_summdat2 <- as.data.frame(table(FinalDetdat$Code_timing_FIN, FinalDetdat$Code_strict_FIN))
table_summdat2 <- table_summdat2[-c(3,6,9,13,14),c(2,1,3)] 
table_summdat2$Perc <- format(round((100*table_summdat2$Freq/275), digits = 2), n_small = 2)

table_summdat2$Freq <- paste(table_summdat2$Freq, table_summdat2$Perc, sep = " (")
table_summdat2$Freq <- paste(table_summdat2$Freq, "%)", sep = "")
table_summdat2 <- table_summdat2[,-4]

colnames(table_summdat2) <- c("Strictness of the policy", "When is code expected to be shared?", "Code policy (# journals)")
#write.csv(table_summdat2, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_FinDet2.csv", row.names = FALSE)



#### II.G. Culina Roche comparisons ---- 

#code mandates-encouragement
compdat_culina <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/compdat_culina.csv")
#"Amongst 96 ecological journals originally assessed for code-sharing policies by Mislan and colleagues [13], 
#the number of journals with mandatory or encouraged code-sharing policies has increased from 14 in 2015 (15%; [13]) 
#to 72 in 2020 (75%; S1 Table in https://asanchez-tojar.github.io/code_in_ecology/supporting_information.html). 
#This is an encouraging increase that implies that the importance of code-sharing is now widely recognized. 
#However, the existence of code-sharing policies does not necessarily translate into code availability (see below).


compdat_culina$Journal <- tolower(compdat_culina$Journal)
setdiff(compdat_culina$Journal, FinalDetdat$Journals)
#journal of the north american benthological society is in culina but not ours (is obsolete so can ignore)
intersect(compdat_culina$Journal, FinalDetdat$Journals)


table(compdat_culina$Culina)
#72/96 = their 75% 
#72/95 when considering only the overlapping 95

compculina_FinalDetdat <- subset(FinalDetdat, Journals %in% compdat_culina$Journal)
table(compculina_FinalDetdat$Code_strict_FIN)
##87/95

Conttab_culina <- NULL
Conttab_culina$Culina <- c(72,23) 
Conttab_culina$Now <- c(87,8) 
Conttab_culina <- as.data.frame(Conttab_culina)
rownames(Conttab_culina) <- c("Yes","No")
chi_culina <- chisq.test(Conttab_culina)
chi_culina

Conttab_culina2 <- NULL
Conttab_culina2$Culina <- c(72,23) 
Conttab_culina2$Now <- c(84,11) 
Conttab_culina2 <- as.data.frame(Conttab_culina2)
rownames(Conttab_culina2) <- c("Yes","No")
chi_culina2 <- chisq.test(Conttab_culina2)
chi_culina2


compdat_roche <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/compdat_roche.csv")

compdat_roche$Journal <- tolower(compdat_roche$Journal)
setdiff(compdat_roche$Journal, FinalDetdat$Journals)
#"american journal of physical anthropology" "american midland naturalist"              
#"bmc ecology"                               "bmc evolutionary biology"                 
#"evolutionary ecology research"             "revue d ecologie-la terre et la vie"       
#in roche but not ours (AMN, BMC eco, BMC evo, EER, and RDELTELV not currently operating)
compdat_roche$Journal <- case_when(
  compdat_roche$Journal %in% c("american journal of physical anthropology") ~ "american journal of biological anthropology",
  .default = compdat_roche$Journal
)
intersect(compdat_roche$Journal, FinalDetdat$Journals) #194 in both

compdat_roche_red <- subset(compdat_roche, Journal %in%FinalDetdat$Journals)
comproche_FinalDetdat <- subset(FinalDetdat, Journals %in%compdat_roche$Journal)

table(compdat_roche_red$policy) #69/194, 35.56701% strong;  81/194, 41.75258% weak
table(comproche_FinalDetdat$Data_strict_FIN) #80/194, 41.23711% mandated;  95/194, 48.96907% encouraged, on rev req, optional

#mandate comp
Conttab_rocheA <- NULL
Conttab_rocheA$Roche <- c(69,125) 
Conttab_rocheA$Now <- c(80,114) 
Conttab_rocheA <- as.data.frame(Conttab_rocheA)
rownames(Conttab_rocheA) <- c("Yes","No")
chi_rocheA <- chisq.test(Conttab_rocheA)
chi_rocheA

#mandate + others comp
Conttab_rocheB <- NULL
Conttab_rocheB$Roche <- c(150,44) 
Conttab_rocheB$Now <- c(175,19) 
Conttab_rocheB <- as.data.frame(Conttab_rocheB)
rownames(Conttab_rocheB) <- c("Yes","No")
chi_rocheB <- chisq.test(Conttab_rocheB)
chi_rocheB


#### II.H. Specific Hypothesis based on the final determinations ----


#Hypothesis I: Journals with a stricter data-sharing policy will also have a stricter code-sharing policy [1 hypothesis].

corr_strictdat_strictcode <- ci_cramersv(FinalDetdat[,c(9,11)])
corr_strictdat_strictcode

round(corr_strictdat_strictcode$estimate, digits = 3) 
round(corr_strictdat_strictcode$interval, digits = 3)


#Hypothesis II: Journals will have similar levels of timing for both data and code [1 hypothesis].

corr_timingdat_timingcode <- ci_cramersv(FinalDetdat[,c(8,10)])
corr_timingdat_timingcode

round(corr_timingdat_timingcode$estimate, digits = 3) 
round(corr_timingdat_timingcode$interval, digits = 3)


#Hypothesis III: Journals with stricter code- and data-sharing policies will have policies with high clarity scores [1 hypothesis for code- and 1 for data-sharing = 2*1].

#Using the median clarity score for the final determinations (data).
H01_respB_datclar$How.clear.do.you.think.this.statement.is.NUM <- as.numeric(H01_respB_datclar$How.clear.do.you.think.this.statement.is.)
H01_respB_dat_clarFIN <- setDT(H01_respB_datclar)[ , list(Data_clarit_FIN = median(How.clear.do.you.think.this.statement.is.NUM)),
                                                  by = .(Name.of.Journal)]
colnames(H01_respB_dat_clarFIN) <- c("Journals", "Data_clarit_FIN")
FinalDetdat_datclar <- merge(FinalDetdat, H01_respB_dat_clarFIN, by = "Journals", all.x = FALSE)
labels(FinalDetdat_datclar)
nrow(FinalDetdat_datclar)

FinalDetdat_datclar$Data_strict_FIN <- ordered(FinalDetdat_datclar$Data_strict_FIN, levels = c("Mandated", "Encouraged", "On Reviewer Request", 
                                                                                               "Optional for Authors"))
FinalDetdat_datclar$Data_clarit_FIN <- as.character(FinalDetdat_datclar$Data_clarit_FIN)
FinalDetdat_datclar$Data_clarit_FIN <- ordered(FinalDetdat_datclar$Data_clarit_FIN, levels = c("1", "2", "3", "4", "5"))

corr_strictdat_timingdata <- ci_cramersv(FinalDetdat_datclar[,c(9,12)])
corr_strictdat_timingdata

round(corr_strictdat_timingdata$estimate, digits = 3) 
round(corr_strictdat_timingdata$interval, digits = 3)


#plot(FinalDetdat_datclar$Data_strict_FIN, FinalDetdat_datclar$Data_clarit_FIN) 

FinalDetdat_datclar$Data_clarit_FIN <- as.numeric(FinalDetdat_datclar$Data_clarit_FIN)
Datclar_bystrict <- setDT(FinalDetdat_datclar)[ , list(Mean_clar = mean(Data_clarit_FIN),
                                                       Median_clar = median(Data_clarit_FIN),
                                                       SD_clar = sd(Data_clarit_FIN)),
                                                   by = .(Data_strict_FIN)]
Datclar_bystrict
mean(FinalDetdat_datclar$Data_clarit_FIN)
median(FinalDetdat_datclar$Data_clarit_FIN)
sd(FinalDetdat_datclar$Data_clarit_FIN)


#Using the median clarity score for the final determinations (code). 
H01_respB_codclar$How.clear.do.you.think.this.statement.is..1NUM <- as.numeric(H01_respB_codclar$How.clear.do.you.think.this.statement.is..1)
H01_respB_cod_clarFIN <- setDT(H01_respB_codclar)[ , list(Code_clarit_FIN = median(How.clear.do.you.think.this.statement.is..1NUM)),
                                                   by = .(Name.of.Journal)]
colnames(H01_respB_cod_clarFIN) <- c("Journals", "Code_clarit_FIN")
FinalDetdat_codclar <- merge(FinalDetdat, H01_respB_cod_clarFIN, by = "Journals", all.x = FALSE)
labels(FinalDetdat_codclar)
nrow(FinalDetdat_codclar)

FinalDetdat_codclar$Code_strict_FIN <- ordered(FinalDetdat_codclar$Code_strict_FIN, levels = c("Mandated", "Encouraged", "On Reviewer Request", 
                                                                                               "Optional for Authors"))
FinalDetdat_codclar$Code_clarit_FIN <- as.character(FinalDetdat_codclar$Code_clarit_FIN)
FinalDetdat_codclar$Code_clarit_FIN <- ordered(FinalDetdat_codclar$Code_clarit_FIN, levels = c("1", "2", "3", "4", "5"))

corr_strictcod_timingdata <- ci_cramersv(FinalDetdat_codclar[,c(9,12)])
corr_strictcod_timingdata

round(corr_strictcod_timingdata$estimate, digits = 3) 
round(corr_strictcod_timingdata$interval, digits = 3)

#plot(FinalDetdat_codclar$Code_strict_FIN, FinalDetdat_codclar$Code_clarit_FIN) 

FinalDetdat_codclar$Code_clarit_FIN <- as.numeric(FinalDetdat_codclar$Code_clarit_FIN)
Codclar_bystrict <- setDT(FinalDetdat_codclar)[ , list(Mean_clar = mean(Code_clarit_FIN),
                                                       Median_clar = median(Code_clarit_FIN),
                                                       SD_clar = sd(Code_clarit_FIN)),
                                                by = .(Code_strict_FIN)]
Codclar_bystrict
mean(FinalDetdat_codclar$Code_clarit_FIN)
median(FinalDetdat_codclar$Code_clarit_FIN)
sd(FinalDetdat_codclar$Code_clarit_FIN)


#Hypothesis IV: The number of journals encouraging or mandating code- and data-sharing “During Peer Review” will be different than the number encouraging or mandating “After Acceptance”  [1 hypothesis for code- and 1 for data-sharing = 2*1].

FinalDetdat_Data_mandenco <- subset(FinalDetdat, Data_strict_FIN %in% c("Mandated", "Encouraged"))
comdata_datatiming <- as.data.frame(table(FinalDetdat_Data_mandenco$Data_timing_FIN))
comdata_datatiming$Perc <- (comdata_datatiming$Freq/167)*100
comdata_datatiming <- comdata_datatiming[-3,]

chi_datatiming <- chisq.test(comdata_datatiming$Freq, p = c(0.5, 0.5))
chi_datatiming #similar proportion of journals require data at the peer review and after acceptance phase. 


FinalDetdat_Code_mandenco <- subset(FinalDetdat, Code_strict_FIN %in% c("Mandated", "Encouraged"))
comdata_codetiming <- as.data.frame(table(FinalDetdat_Code_mandenco$Code_timing_FIN))
comdata_codetiming$Perc <- (comdata_codetiming$Freq/147)*100
comdata_codetiming <- comdata_codetiming[-3,]

chi_codetiming <- chisq.test(comdata_codetiming$Freq, p = c(0.5, 0.5))
chi_codetiming #similar proportion of journals require data at the peer review and after acceptance phase. 



#Building dataset for [redacted]
FinalDetdat_compiled <- FinalDetdat[,c(1,8:11)]
labels(FinalDetdat_compiled)
labels(FinalDetdat_datclar)

FinalDetdat_compiled <- merge(FinalDetdat_compiled, FinalDetdat_datclar[,c(1,12)], all.x = TRUE)
FinalDetdat_compiled <- merge(FinalDetdat_compiled, FinalDetdat_codclar[,c(1,12)], all.x = TRUE)

FinalDetdat_compiled$Data_clarit_FIN <- as.character(FinalDetdat_compiled$Data_clarit_FIN)
FinalDetdat_compiled$Code_clarit_FIN <- as.character(FinalDetdat_compiled$Code_clarit_FIN)

FinalDetdat_compiled$Data_clarit_FIN <- case_when(
  FinalDetdat_compiled$Data_clarit_FIN  %in% c("NA", NA) ~ "NA (no policy)",
  .default = FinalDetdat_compiled$Data_clarit_FIN 
)
FinalDetdat_compiled$Code_clarit_FIN <- case_when(
  FinalDetdat_compiled$Code_clarit_FIN  %in% c("NA", NA) ~ "NA (no policy)",
  .default = FinalDetdat_compiled$Code_clarit_FIN 
)

FinalDetdat_compiled <- FinalDetdat_compiled[,c(1,2,3,6,4,5,7)]

#write.csv(FinalDetdat_compiled, "~/OpenDataCode_Analysis_OSF/FinalPolicyDeterminations_compiled.csv", row.names = FALSE)
