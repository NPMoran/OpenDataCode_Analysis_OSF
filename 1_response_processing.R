#Project: From Policy to Practice: Progress towards Data- and Code-Sharing in Ecology and Evolution
#
#Date: 2024, v0.1
#
#Author: [redacted]


#NOTE: DUE TO ANONYMISATION AND PRIVACY REQUIREMENTS FOR REVIEW AND PUBLICATION, ALL DATASETS IN THIS SCRIPT CONTANING EMAIL ADDRESSES AND AUTHOR NAMES HAVE BEEN REDACTED.
#      AS A RESULT, SOME SECTIONS OF SCRIPT WHERE PROCESSING IS BASED ON AUTHOR NAMES/ADDRESSES ARE NON-FUNCTIONAL,
#      PARTS OF THE SCRIPT HAVE THEREFORE BEEN DISABLED, BUT ARE STILL INCLUDED FOR TRANSPARENCY. 
#      ALL OUTPUT AND INTERIM PROCESSING FILES ARE ALSO STILL INCLUDED


#loading required packages
library(tidyverse)


##### I.A. Initial Processing DE Response Data ----
#
##Importing data
#H01_respA <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/H01_responses_07022024.csv", strip.white = TRUE)
#H01_respB <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/H01_responses_07022024_corrections.csv", strip.white = TRUE)
#H01_allo <- read.csv("~/OpenDataCode_Analysis_OSF/subset_assignments/H01_subset_assigments_13122023.csv", strip.white = TRUE)
#
#
##Checking allocations
## - removing 4th round, not allocated to anyone
#H01_allo <- subset(H01_allo, subset_number <= 57)
#nrow(H01_allo) #852
#
## - removing 5 duplicated/obsolete journals (4x3 and 1x2 rows removed, one extra allocation 'natural history' will need to be corrected)
#H01_allo <- subset(H01_allo, assigned_to_email != "NA")
#nrow(H01_allo) #838 were allocated 
#
#nrow(subset(H01_allo, assigned_to_email != "")) #838 allocated
#nrow(subset(H01_allo, assigned_to_email == "")) #0 remaining to be allocated
#
#
##Checking responses
#nrow(H01_respA) #871 #total responses submitted
#nrow(H01_respB) #838 (i.e., 33 removed entirely due to data entry or duplication/obsolescence issues)
#
#table(H01_respB$Email.Address)
#table(H01_allo$assigned_to_email)
#
#H01_respB$Email.Address <- case_when(
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  H01_respB$Email.Address %in% c("REDACTED@REDACTED.COM") ~ "REDACTED@REDACTED.COM"
#  .default = H01_respB$Email.Address
#)
#
#resp <- as.data.frame(table(H01_respB$Email.Address))
#allo <- as.data.frame(table(H01_allo$assigned_to_email))
#
#setdiff(resp$Var1, allo$Var1)
#setdiff(allo$Var1, resp$Var1)
#
#check <- merge(allo, resp, by = "Var1", all.x = TRUE)
#check$diff <- check$Freq.x - check$Freq.y
#check #all allocations complete!!
#
##PREVIOUS SUPERCEEDED CHECKS
##Remaining allocated sets (as of 13/12/23)
## [REDACTED]
#
##Remaining allocated sets (as of 07/12/23)
## [REDACTED]
#
##Extra entries
## [REDACTED]
#
##Remaining sets (as of 27/11/23)
## [REDACTED]
#
##Missing responses due to deduplication or other issues (so don't require reminder)
## [REDACTED]
#
##As of 1/12/23, 
## [REDACTED]
#
#
##Checking remaining journals to be completed. 
#
#H01_respB$Name.of.Journal <- str_to_lower(H01_respB$Name.of.Journal)
#
#H01_respB$Name.of.Journal <- case_when(
#  H01_respB$Name.of.Journal %in% c(",insect systematics & evolution") ~ "insect systematics & evolution",
#  H01_respB$Name.of.Journal %in% c("chan") ~ "community ecology",
#  H01_respB$Name.of.Journal %in% c("ecodevo") ~ "evodevo",
#  H01_respB$Name.of.Journal %in% c("ethology ecology & evolution") ~ "ethology, ecology and evolution",
#  H01_respB$Name.of.Journal %in% c("evolution, medicine, and public health") ~ "evolution medicine and public health",
#  H01_respB$Name.of.Journal %in% c("fire") ~ "fire-switzerland",
#  H01_respB$Name.of.Journal %in% c("genome biology") ~ "genome biology and evolution",
#  H01_respB$Name.of.Journal %in% c("human wildlife interactions") ~ "human-wildlife interactions",
#  H01_respB$Name.of.Journal %in% c("plankton biology and ecology", "plankton and benthos research") ~ 'plankton biology and ecology ( "plankton biology and ecology" has changed name to "plankton and benthos research" in 2006)',
#  H01_respB$Name.of.Journal %in% c("natural history") ~ 'journal of natural history',
#    .default = H01_respB$Name.of.Journal
#)
#
#j_count_allo <- as.data.frame(table(H01_allo$Journal))
#j_count_allo <- subset(j_count_allo, Var1 != "natural history")
#
#j_count_resp <- as.data.frame(table(H01_respB$Name.of.Journal))
#
#nrow(j_count_resp)
#nrow(j_count_allo)
#setdiff(j_count_resp$Var1,j_count_allo$Var1)
#setdiff(j_count_allo$Var1,j_count_resp$Var1)
#
#H01_notallocated <- subset(H01_allo, assigned_to_email == "")
#nrow(H01_notallocated) #all remaining allocated
#
#j_count <- merge(j_count_allo, j_count_resp, by = 'Var1', all.x = TRUE)
#
#colnames(j_count) <- c("Journal", "Resp_required", "Resp_received")
#
#
#j_count$Remaining_incomplete <- (j_count$Resp_required - j_count$Resp_received)
#j_count[174,4] <- 0 #changing journal of natural history to 0.
#
#sum(j_count$Resp_required)  #837 total responses required (3x 279 journals)
#sum(j_count$Resp_received)  #838 required responses received (100.0% of total requirement), one extra for J of Nat His
#sum(j_count$Remaining_incomplete)  #0 allocated but incomplete
#
#
#
##write.csv(H01_respB, "~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_processed.csv", row.names = FALSE)



#### I.B. Resolving 'Others' entries ----

H01_respB <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_processed-ANON.csv", strip.white= TRUE)
labels(H01_respB)


#Dealing with others
#Timing rating (data)
table(H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided.)
#After Acceptance (Post-Publication)  134
#During Peer Review;                  221
#Not Expected At All;                 167
#Unclear                              287

H01_respB_others_Data <- subset(H01_respB, !(When.was.the.earliest.the.journal.expected.data.to.be.provided. 
                                             %in% c("After Acceptance (Post-Publication)", "During Peer Review",
                                                    "Not Expected At All", "Unclear")))
nrow(H01_respB_others_Data) #29
H01_respB_others_Data <- H01_respB_others_Data[,c(1:5, 10)]


#Dealing with others
#Timing rating (data)
table(H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided.)
#After Acceptance (Post-Publication)  69 
#During Peer Review;                  136 
#Not Expected At All;                 356 
#Unclear                              253 

H01_respB_others_Code <- subset(H01_respB, !(When.was.the.earliest.the.journal.expected.code.to.be.provided. 
                                             %in% c("After Acceptance (Post-Publication)", "During Peer Review",
                                                    "Not Expected At All", "Unclear")))
nrow(H01_respB_others_Code) #24
H01_respB_others_Code <- H01_respB_others_Code[,c(1:4,11,16)]


#write.csv(H01_respB_others_Data, "~/OpenDataCode_Analysis_OSF/data_responses/processing_others/H01_respB_others_Data.csv", row.names = FALSE)
#write.csv(H01_respB_others_Code, "~/OpenDataCode_Analysis_OSF/data_responses/processing_others/H01_respB_others_Code.csv", row.names = FALSE)


#Strictness rating: 
table(H01_respB$How.strict.is.this.policy...Data.policy.) #all 838 responses included
table(H01_respB$How.strict.is.this.policy...Code.Policy.) #all 838 responses included



#Re-categorisations based on [redacted] decisions 
#H01_respB_others_Data_complete <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/processing_others/H01_respB_others_Data_complete.csv", strip.white= TRUE)
#H01_respB_others_Code_complete <- read.csv("~/OpenDataCode_Analysis_OSF/data_responses/processing_others/H01_respB_others_Code_complete.csv", strip.white= TRUE)
#
#H01_respB_others_Data_complete$MergeID <- paste(H01_respB_others_Data_complete$Email.Address, H01_respB_others_Data_complete$Name.of.Journal)
#H01_respB_others_Code_complete$MergeID <- paste(H01_respB_others_Code_complete$Email.Address, H01_respB_others_Code_complete$Name.of.Journal)
#H01_respB_others_Data_complete <- H01_respB_others_Data_complete[, c(7,10)]
#H01_respB_others_Code_complete <- H01_respB_others_Code_complete[, c(7,10)]
#
#H01_respB$MergeID <- paste(H01_respB$Email.Address, H01_respB$Name.of.Journal)
##intersect(H01_respB_others_Data_complete$MergeID, H01_respB$MergeID)
#
#H01_respB_others_workingdata <- subset(H01_respB, !(MergeID %in% H01_respB_others_Data_complete$MergeID))
#H01_respB_others_workingdata <- H01_respB_others_workingdata[,c(5,17)]
#colnames(H01_respB_others_Data_complete) <- colnames(H01_respB_others_workingdata)
#H01_respB_others_workingdata <- rbind(H01_respB_others_workingdata, H01_respB_others_Data_complete)
#
#nrow(H01_respB_others_workingdata)
#n_distinct(H01_respB_others_workingdata$MergeID)
#
#H01_respB <- merge(H01_respB, H01_respB_others_workingdata, by = "MergeID", all.x= TRUE)
#H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided..x <- H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided..y
#H01_respB$When.was.the.earliest.the.journal.expected.data.to.be.provided..y <- NULL
#
#
#
#H01_respB_others_workingcode <- subset(H01_respB, !(MergeID %in% H01_respB_others_Code_complete$MergeID))
#H01_respB_others_workingcode <- H01_respB_others_workingcode[,c(12,1)]
#colnames(H01_respB_others_Code_complete) <- colnames(H01_respB_others_workingcode)
#H01_respB_others_workingcode <- rbind(H01_respB_others_workingcode, H01_respB_others_Code_complete)
#
#nrow(H01_respB_others_workingcode)
#n_distinct(H01_respB_others_workingcode$MergeID)
#
#H01_respB <- merge(H01_respB, H01_respB_others_workingcode, by = "MergeID", all.x= TRUE)
#H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided..x <- H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided..y
#H01_respB$When.was.the.earliest.the.journal.expected.code.to.be.provided..y <- NULL
#
##write.csv(H01_respB, "~/OpenDataCode_Analysis_OSF/data_responses/H01_resp_processed_others.csv", row.names = FALSE)

