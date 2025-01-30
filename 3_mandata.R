#Project: From Policy to Practice: Progress towards Data- and Code-Sharing in Ecology and Evolution
#
#Date: 2024, v0.1
#
#Author: [redacted]


#NOTE: DUE TO ANONYMISATION AND PRIVACY REQUIREMENTS FOR REVIEW AND PUBLICATION, ALL DATASETS IN THIS SCRIPT CONTANING POTENTIALLY 
#      IDENTIFYING INFORMATION HAVE BEEN REDACTED, INCLUDING MANUSCRIPT IDS, AND TEXT QUESTION RESPONSES. 
#      AS A RESULT, SOME DATA PRE-PROCESSING SECTIONS ARE NON-FUNCTIONAL AND HAVE THEREFORE BEEN DISABLED, THESE SECTIONS
#      ARE STILL INCLUDED FOR TRANSPARENCY, AND ALL OUTPUT AND INTERIM PROCESSING FILES ARE ALSO STILL INCLUDED.


#loading required packages
library(tidyverse); library(lubridate); library(readxl); library(data.table)


#### II.A. Eco Letts ----
mandata_EL_2021 <- read_excel("~/OpenDataCode_Analysis_OSF/data_mandatejournals/ELE data-ANON.xlsx", sheet = "Jun-Aug 21", skip = 2)
nrow(mandata_EL_2021) #280 submissions
n_distinct(mandata_EL_2021$`Manuscript ID`) #all single (1st) submissions

table(mandata_EL_2021$`Compliant data statement provided at initial submission? (y/n/unknown)`) 
#79 EIC desk rejections excldued from analysis, no data. 

mandata_EL_2021_red <- subset(mandata_EL_2021, `Compliant data statement provided at initial submission? (y/n/unknown)` != "unknown")
comdata_EL_2021 <- as.data.frame(table(mandata_EL_2021_red$`Compliant data statement provided at initial submission? (y/n/unknown)`))
comdata_EL_2021$Var1 <- c("No", "Yes")
comdata_EL_2021$Perc <- 100*(comdata_EL_2021$Freq/201) 

mandata_EL_2021_comp <- subset(mandata_EL_2021_red, `Compliant data statement provided at initial submission? (y/n/unknown)` == "y")
comdata_EL_2021how <- as.data.frame(table(mandata_EL_2021_comp$`Details of data statement`))
comdata_EL_2021how$Perc <- 100*(comdata_EL_2021how$Freq/201) 
comdata_EL_2021how

#comdata_EL_2021$Period <- "2021"
#comdata_EL_2021how$Period <- "2021"


#Notes Re: Compliance in 2023: 
#  -  Yes = A data statement provided on submission (stating the availability of data/code via a DOI, or saying it will be provided on acceptance). 
#           

#Caveats, 
#  -  EIC desk rejections were excluded from this and not from 2023 (unclear if that has any effect)



mandata_EL_2023 <- read_excel("~/OpenDataCode_Analysis_OSF/data_mandatejournals/ELE data-ANON.xlsx", sheet = "Sept-Nov 23", skip = 2)
nrow(mandata_EL_2023) #291 submissions
n_distinct(mandata_EL_2023$`Manuscript ID`) #291, all single (1st) submissions

comdata_EL_2023 <- as.data.frame(table(mandata_EL_2023$`Compliant DOI provided at initial submission? (y/n)`))
comdata_EL_2023$Var1 <- c("No", "Yes")
comdata_EL_2023$Perc <- 100*(comdata_EL_2023$Freq/291)
comdata_EL_2023

#comdata_EL_2023$Period <- "2023"

#Notes Re: Compliance in 2023: 
#  -  Yes = A working DOI (or review link) on submission. 
#           Requirement applies to both data and code.
#           Repositories are not inspected beyond checking that it matches the manuscript. 
#           Data editors do check repos, but just prior to final acceptance.
#           
#  -  No = A DOI or link is not provided  
#          OR A DOI/link is provided and doesn't work, or is provided and is for the incorrect manuscript.       
#          (Note: this may include papers with no data/code, but as these are Letters articles, they are likely to be very few.)




#Statistical tests
# • For journal-specific submission data, the main variable measured will be the proportion of submissions (i.e., of the total of research papers), that:
#   - are compliant with the current data/code submission policy, and
#   - provide data/code on submission via a DOI/link (for Eco Let data only).

#• For Eco Let data, this will be stratified by:
#  - Pre- and post-policy implementation.

#- We will conduct Chi-squared tests to assess 
# VII) whether the number of papers that share data and code differs from those that don’t 
#      (observed = number of studies that do/do not share data or code, expected = equal number of studies that do/do not share data and code) 
# VIII) whether data-sharing differs from code-sharing frequency 
#      (observed = number of studies with data and code-sharing, expected = equal number of studies that share either code or data) and 
# IX) for Eco Let only, whether there is greater code- or data-sharing pre- and post-mandate 
#     (observed = number of studies with data and code-sharing pre/post-mandate, expected = equal number of studies with data and code-sharing pre/post-mandate).



# VII) 
#compliance versus non-compliance 2021 (pre-mandate)
chi_comp2021 <- chisq.test(comdata_EL_2021$Freq, p = c(0.5, 0.5))
chi_comp2021 #sig. higher compliance versus non-compliance

#doi/link versus not shared for peer review 2021 (pre-mandate)
chi_link2021 <- chisq.test(c(comdata_EL_2021how[1,2],(comdata_EL_2021how[2,2]+comdata_EL_2021[1,2])), p = c(0.5, 0.5))
chi_link2021 #sig. lower DOI/link sharing for review than not sharing

#compliance versus non-compliance 2023 & doi/link versus not shared for peer review 2021(pre-mandate)
chi_complink2023 <- chisq.test(comdata_EL_2023$Freq, p = c(0.5, 0.5))
chi_complink2023 #sig. lower compliance versus non-compliance, sig. lower DOI/link sharing than not sharing



# VIII) 
# -  this is not testable with Eco Letts data, as code and data submissions cannot be distinguished.



# IX) 
#compliance 2021 versus 2023
Conttab_comp <- cbind(comdata_EL_2021$Freq, comdata_EL_2023$Freq)
colnames(Conttab_comp) <- c("2021", "2023")
rownames(Conttab_comp) <- c("No", "Yes")

chi_comp21v23 <- chisq.test(Conttab_comp)
chi_comp21v23 #significantly lower compliance in the 2023 than 2021


Conttab_link <- Conttab_comp
Conttab_link[1,1] <- Conttab_link[1,1] + comdata_EL_2021how[2,2] #adding the doi on acceptance statements to the no count
Conttab_link[2,1] <- comdata_EL_2021how[1,2] #setting the yes count to those with DOIs

#link sharing 2021 versus 2023 
chi_link21v23 <- chisq.test(Conttab_link)
chi_link21v23 #significantly higher rate of doi/link sharing for peer review in 2023 than 2021


Table_mandata1 <- rbind(as.data.frame(Conttab_comp),
                         as.data.frame(Conttab_link))

Table_mandata1$`2021` <- paste(Table_mandata1$`2021`, format(round((100*Table_mandata1$`2021`/201), digits = 2), nsmall = 2), sep = " (")
Table_mandata1$`2021` <- paste(Table_mandata1$`2021`, "%)", sep = "")

Table_mandata1$`2023` <- paste(Table_mandata1$`2023`, format(round((100*Table_mandata1$`2023`/291), digits = 2), nsmall = 2), sep = " (")
Table_mandata1$`2023` <- paste(Table_mandata1$`2023`, "%)", sep = "")

#write.csv(Table_mandata1, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_mandata1.csv", row.names = FALSE)

Table_mandata2 <- NULL
Table_mandata2$chi <- c(chi_comp2021$statistic,
                        chi_link2021$statistic,
                        chi_complink2023$statistic,
                        chi_comp21v23$statistic,
                        chi_link21v23$statistic)
Table_mandata2$pvl <- c(chi_comp2021$p.value,
                        chi_link2021$p.value,
                        chi_complink2023$p.value,
                        chi_comp21v23$p.value,
                        chi_link21v23$p.value)
Table_mandata2 <- as.data.frame(Table_mandata2)

Table_mandata2$text <- paste(format(round((Table_mandata2$chi), digits = 3), nsmall = 3),
                             format(round((Table_mandata2$pvl), digits = 3), nsmall = 3), sep = " (P = ")
Table_mandata2$text <- paste(Table_mandata2$text, ")", sep = "")

#write.csv(Table_mandata2, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_mandata2.csv", row.names = FALSE)


#### II.B. Proc B ----

# - Importing and formatting new database
#proc_b_newnew <- read.csv("~/OpenDataCode_Analysis_OSF/data_mandatejournals/Proc_B_reextraction report.csv")
#nrow(proc_b_newnew) #4680
#labels(proc_b_newnew)
#proc_b_newnew$Submission.Date <- dmy_hm(proc_b_newnew$Submission.Date)
#summary(proc_b_newnew$Submission.Date) #2023-03-10 - 2024-02-28
##Data query:
##Include Only Original Submissions 
##AND Submission Date: On or after 9 Mar 2023 
##AND Submission Question: Does your paper present new data, or use data/models published elsewhere?, If ...			
#
#
#nrow(proc_b_newnew) #4680
#n_distinct(proc_b_newnew$Manuscript.ID) #2340
#
#table(proc_b_newnew$Submission.Question)
#table(proc_b_newnew$Manuscript.Type)
#table(proc_b_newnew$Manuscript.Type.1)
#
#proc_b_newnew_1 <- subset(proc_b_newnew, Submission.Question == "Does your paper present new data, or use data/models published elsewhere?")
#proc_b_newnew_2 <- subset(proc_b_newnew, Submission.Question == "If yes, provide a link to your data if it is in a repository. If depositing your data with Dryad, <b>ensure that you give the private reviewer 'sharing' link</b>. If your data is uploaded as supplementary material, please state this. Your paper will be unsubmitted without this information.")
#labels(proc_b_newnew_2)
#
#proc_b_newnew_1_reduced <- proc_b_newnew_1[,c(1,2,6)]
#proc_b_newnew_2_reduced <- proc_b_newnew_2[,c(1,6)]
#
#proc_b_newnew_combined <- merge(proc_b_newnew_1_reduced, proc_b_newnew_2_reduced, by = "Manuscript.ID", all.x = TRUE)
#nrow(proc_b_newnew_combined) #2340
#n_distinct(proc_b_newnew_combined$Manuscript.ID) #2340
#
#
# - Preliminary summary stats
#write.csv(proc_b_newnew_combined, "~/OpenDataCode_Analysis_OSF/data_mandatejournals/Proc_B_newnew_combined.csv", row.names = FALSE)
proc_b_newnew_combined <- read.csv("~/OpenDataCode_Analysis_OSF/data_mandatejournals/Proc_B_newnew_combined-ANON.csv")

#Data exploration
table(proc_b_newnew_combined$Manuscript.Type)

table(proc_b_newnew_combined$Submission.Question.Response.x) 
#note: [redacted ID] didn't answer any questions.

#table(proc_b_newnew_combined$Submission.Question.Response.y) 
#nrow(as.data.frame(table(proc_b_newnew_combined$Submission.Question.Response.y))) #1954 individual responses from 

prob_b_quesA <- as.data.frame(table(subset(proc_b_newnew_combined, Submission.Question.Response.x != "")$Manuscript.Type, 
                                    subset(proc_b_newnew_combined, Submission.Question.Response.x != "")$Submission.Question.Response.x))

prob_b_quesA_w1 <- subset(prob_b_quesA, Var2 == "My paper has no data")
prob_b_quesA_w2 <- subset(prob_b_quesA, Var2 == "Yes")

prob_b_quesA <- merge(prob_b_quesA_w1, prob_b_quesA_w2, by = 'Var1', all.x = TRUE)
prob_b_quesA <- prob_b_quesA[,-c(2,4)]
colnames(prob_b_quesA) <- c("Manuscript.Type", "My paper has no data", "Yes")

prob_b_quesA$Perc <- round(((prob_b_quesA$Yes/(prob_b_quesA$Yes+prob_b_quesA$`My paper has no data`)))*100, digits = 1)
prob_b_quesA <- prob_b_quesA[order(prob_b_quesA$Perc,decreasing=TRUE),]
prob_b_quesA$Perc <- paste(prob_b_quesA$Perc, "%", sep = "")
prob_b_quesA


#write.csv(prob_b_quesA, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_mandata3.csv", row.names = FALSE)


#Journal-specific submission data:
#VII.  Submissions will share data or code more often than not sharing [1 hypothesis].
#VIII. Data-sharing will be more frequent than code-sharing [1 hypothesis].
#IX.   There will be greater code- and data-sharing during peer review after the journal’s implementation of mandated sharing policies. 
#      [1 hypothesis for code- and 1 for data-sharing = 2*1].



#Part 2. Journal-specific data.
#For journal-specific submission data, the main variable measured will be the proportion of submissions...
#(i.e., of the total of research papers), that:
#  - are compliant with the current data/code submission policy, and
#  - provide data/code on submission via a DOI/link (for Eco Let data only).
#
#• For Proc B data, research papers will be stratified by:
#  - Article type (e.g., research article, review, commentary, etc.)
#  - Location of open data/code (repository, supplementary material, etc).

#Thus, compliance will be determined based simply on whether the authors appear to have complied with the code/data policy in principle 
#(i.e., provided a DOI/link, or stated that they have uploaded supplementary files).


## Statistical models
#• Relating to hypotheses VII-IX: 
#  - We will conduct Chi-squared tests to assess VII) whether the number of papers that share data and code differs from those that don’t 
#    (observed = number of studies that do/do not share data or code, expected = equal number of studies that do/do not share data and code) 
#    VIII) whether data-sharing differs from code-sharing frequency (observed = number of studies with data and code-sharing, expected = equal number of studies that share either code or data) and IX) for Eco Let only, whether there is greater code- or data-sharing pre- and post-mandate (observed = number of studies with data and code-sharing pre/post-mandate, expected = equal number of studies with data and code-sharing pre/post-mandate).

## Transformations
#For the journal Proc B, all data will be categorised as post-mandate. 
#Based on communication with the journal, the policy has been in place since 2017, and pre-mandate data on submissions could therefore not be obtained.

#From the data provided, where possible, we will categorise submissions based on:
#  - The proportion of total submissions that comply with the policy by providing some data/code (i.e., compliant versus non-compliant).
#  - Article type (e.g., research article, review, commentary, etc.) to then distinguish articles that would not be expected to require data/code alongside (i.e., data/code expected versus non-expected; e.g. ‘research’ = expected whereas ‘review’ = not expected)
#  - How the submission appears to comply with the mandate (e.g., deposited in a repository like Dryad/Zenodo/OSF, other platforms such as GitHub, or presented in the supplementary material).


##Exploratory analysis
#  3 -  How does the proportion of papers with data and code differ depending on the manuscript type (Proc B only)?
#  4 -  What is the proportion of papers that provide data or code via supplementary files submitted to the journal versus those complying via DOIs/links to repositories?
#
#To answer both of these we will calculate descriptive statistics in the form of percentages stratified by the appropriate variable (manuscript type or location of data/code). 


#Processing question 2 responses.
#proc_b_research_yes <- subset(proc_b_newnew_combined, Manuscript.Type == "Research")
#proc_b_research_yes <- subset(proc_b_research_yes, Submission.Question.Response.x == "Yes")
#nrow(proc_b_research_yes)
#
#
##Searching for apparent links, supplements, data, code 
##(note, this was used to inform manual coding of responses)
#Manuscript.ID = proc_b_research_yes$Manuscript.ID
#Submission.Question.Response.y = proc_b_research_yes$Submission.Question.Response.y
#list_A <- c("https", "github", "gitlab", "osf", "dryad", "doi", "figshare", 
#                   "zenodo", "com", ".org", "link")
#list_B <- c("supplement", "ESM", "uploaded")
#list_C <- c("data")
#list_D <- c("code", "script")
#
#Pattern_A = paste(list_A, collapse="|")
#Pattern_B = paste(list_B, collapse="|")
#Pattern_C = paste(list_C, collapse="|")
#Pattern_D = paste(list_D, collapse="|")
#
#DT_result <- data.table(Manuscript.ID, Submission.Question.Response.y, 
#                        appar_link=grepl(Pattern_A, Submission.Question.Response.y, ignore.case = TRUE),
#                        appar_supp=grepl(Pattern_B, Submission.Question.Response.y, ignore.case = TRUE),
#                        appar_data=grepl(Pattern_C, Submission.Question.Response.y, ignore.case = TRUE),
#                        appar_code=grepl(Pattern_D, Submission.Question.Response.y, ignore.case = TRUE))
#
#table(DT_result$appar_link)
#table(DT_result$appar_supp)
#table(DT_result$appar_data)
#table(DT_result$appar_code)
#
#
##Variables required
## - Is a link and/or supplementary materials provided? (Yes, No, Unclear)
## - How is it provided (Link, Supplementary materials, Both)
## - Is data and/or code provided (Data, Code, Data and Code, Unclear)
#
#
##write.csv(DT_result, "~/OpenDataCode_Analysis_OSF/data_mandatejournals/proc_b_processing/Proc_B_stringsearch.csv", row.names = FALSE)



#Proc B, Submission Qu Response Data
proc_b_respproc <- read.csv("~/OpenDataCode_Analysis_OSF/data_mandatejournals/proc_b_processing/H01_Proc B Processing_27082024-ANON.csv")

proc_b_respproc <- subset(proc_b_respproc, Is.a.link.and.or.supplementary.materials.provided. != "")
nrow(proc_b_respproc) #2000 processed


procb_table1 <- as.data.frame(table(proc_b_respproc$Is.a.link.and.or.supplementary.materials.provided.))
procb_table1$perc <- format(round(100*(procb_table1$Freq/2000), digits = 2), n_small = 2)
procb_table1 <- procb_table1[c(3,1,2),]
procb_table1$text <- paste(procb_table1$Freq, procb_table1$perc, sep = " (")
procb_table1$text <- paste(procb_table1$text, "%)", sep = "")

#Notes 
# - Statements that only provide accession numbers for genetic sequence data submitted to named online repositories were considered to have not shared a link (note Proc B's policy currently treats these as compliant).
# - Similarly, statements saying accession numbers were provided in supplementary materials, without any other data shared, are not considered to have shared data via supplements or link. 
# - If a generic link was provided to a sequence data repository along with accession numbers, this was considered to have provided a link.  
# - In any other cases where generic link was provided (e.g., just to github, or to a author's github profile), without additional identifying information, this was considered to not have provided a link to the data/code. 

table(subset(proc_b_respproc, Is.a.link.and.or.supplementary.materials.provided. %in% c("No"))$Notes)
table(subset(proc_b_respproc, Is.a.link.and.or.supplementary.materials.provided. %in% c("Unclear"))$Notes)

#Of the 1929 that share link or supps
procb_table2 <- as.data.frame(table(subset(proc_b_respproc, Is.a.link.and.or.supplementary.materials.provided. %in% c("Yes"))$How.is.it.provided.))
procb_table2$perc <- format(round(100*(procb_table2$Freq/1929), digits = 2), n_small = 2)
procb_table2 <- procb_table2[c(2,3,1),]
procb_table2$text <- paste(procb_table2$Freq, procb_table2$perc, sep = " (")
procb_table2$text <- paste(procb_table2$text, "%)", sep = "")

procb_table3 <- as.data.frame(table(subset(proc_b_respproc, Is.a.link.and.or.supplementary.materials.provided. %in% c("Yes"))$Is.data.and.or.code.provided.))
procb_table3$perc <- format(round(100*(procb_table3$Freq/1929), digits = 2), n_small = 2)
procb_table3 <- procb_table3[c(2,1,3,4),]
procb_table3$text <- paste(procb_table3$Freq, procb_table3$perc, sep = " (")
procb_table3$text <- paste(procb_table3$text, "%)", sep = "")

procb_table <- rbind(procb_table1,
                     procb_table2,
                     procb_table3)

#write.csv(procb_table, "~/OpenDataCode_Analysis_OSF/outputs_visualisations/Table_procb.csv", row.names = FALSE)



#Hypothesis test for data versus code sharing

Conttab_ProDC <- NULL
Conttab_ProDC$Data <- c(63+428,869+568)
Conttab_ProDC$Code <- c(869+428,63+568)
Conttab_ProDC <- as.data.frame(Conttab_ProDC)
rownames(Conttab_ProDC) <- c("No", "Yes")

chi_ProcB_DvC <- chisq.test(Conttab_ProDC)
chi_ProcB_DvC #significantly higher apparent rate of data v code sharing

