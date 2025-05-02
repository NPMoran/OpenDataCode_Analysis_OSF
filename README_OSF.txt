###Data and Code Readme for the project: "From Policy to Practice: Progress towards Data- and Code-Sharing in Ecology and Evolution"

###Lead Authors:
[redacted]


###R Session Details --

#R Version 
4.4.1

##Primary R Packages used for analysis and visualisation
confintr v1.02
treemapify v2.5.6
irr v0.84.1

###All R Packages loaded 

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] gridExtra_2.3     treemapify_2.5.6  readxl_1.4.2      rcompanion_2.4.36 confintr_1.0.2    irr_0.84.1       
 [7] lpSolve_5.6.20    data.table_1.15.4 lme4_1.1-33       Matrix_1.6-0      lubridate_1.9.3   forcats_1.0.0    
[13] stringr_1.5.0     dplyr_1.1.4       purrr_1.0.1       readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
[19] ggplot2_3.5.1     tidyverse_2.0.0  

loaded via a namespace (and not attached):
 [1] httr_1.4.7         splines_4.2.3      expm_0.999-7       gld_2.6.6          lmom_3.2          
 [6] stats4_4.2.3       coin_1.4-3         cellranger_1.1.0   pillar_1.9.0       lattice_0.20-45   
[11] glue_1.6.2         minqa_1.2.5        colorspace_2.1-0   sandwich_3.1-0     plyr_1.8.8        
[16] pkgconfig_2.0.3    mvtnorm_1.1-3      scales_1.3.0       rootSolve_1.8.2.4  tzdb_0.4.0        
[21] timechange_0.3.0   proxy_0.4-27       farver_2.1.1       generics_0.1.3     TH.data_1.1-2     
[26] withr_3.0.0        cli_3.6.1          survival_3.5-3     magrittr_2.0.3     fansi_1.0.6       
[31] nlme_3.1-162       MASS_7.3-58.2      class_7.3-21       tools_4.2.3        hms_1.1.3         
[36] lifecycle_1.0.4    matrixStats_1.0.0  multcomp_1.4-26    Exact_3.3          munsell_0.5.0     
[41] compiler_4.2.3     e1071_1.7-14       multcompView_0.1-9 rlang_1.1.0        grid_4.2.3        
[46] nloptr_2.0.3       rstudioapi_0.14    boot_1.3-28.1      DescTools_0.99.54  gtable_0.3.4      
[51] codetools_0.2-19   R6_2.5.1           zoo_1.8-12         knitr_1.44         utf8_1.2.4        
[56] nortest_1.0-4      libcoin_1.0-10     modeltools_0.2-23  stringi_1.7.12     parallel_4.2.3    
[61] Rcpp_1.0.10        ggfittext_0.10.2   vctrs_0.6.5        tidyselect_1.2.1   xfun_0.39         
[66] lmtest_0.9-40     



### GitHub File Details

###R Script Files --

#1_response_processing.R: Initial processing of response data from data extractors (DEs) from journal policy questionnaire.
#2_response_analysis.R: Analysis of journal policy data
#3_mandata.R: Ecology Letters and Proceedings B data analysis
#4_visualisations.R: Graphing code to produce treemaps.



#FinalPolicyDeterminations_compiled.csv
Journals: List of sampled journals
Data_timing_FIN: Final rating for data timing (After Acceptance, During Peer Review, Not Mentioned)
Data_strict_FIN: Final rating data strictness (Mandated, Encouraged, On Reviewer Request, Optional, Not Mentioned)
Data_clarit_FIN: Final rating for data clarity (1-5)
Code_timing_FIN: Final rating for code timing (After Acceptance, During Peer Review, Not Mentioned)
Code_strict_FIN: Final rating for code strictness (Mandated, Encouraged, On Reviewer Request, Optional, Not Mentioned)	
Code_clarit_FIN: Final rating for code clarity (1-5)



###Folders

##FOLDER - data_mandatejournals: Data received from Ecology Letters and Proceedings B journals.

	#Proc_B_reextraction report-ANON.csv  (i.e., data provided by Proc B, in csv format)
	Manuscript.ID: ID of manuscript [redacted]
	Manuscript Type: Type of manuscript submitted
	Submission Date: Date of manuscript submission
	Submission Question: Identifier of submission response question
	Submission Question Response: Response to question [partially redacted]

	#Proc_b_newnew_combined-ANON.csv  (i.e., data provided by Proc B, reformatted for analysis
	Manuscript.ID: ID of manuscript [redacted]
	Manuscript Type: Type of manuscript submitted
	Submission.Question.Response.x: Was there a response to the data question.
	Submission.Question.Response.y: If yes, what information is there. [redacted]

	#ELE data-ANON.xlsx  (i.e., data provided by Eco Letts, in xlsx format)
		Jun-Aug 21 sheet: 
		Manuscript ID: ID of manuscript [redacted]
		Compliant data statement provided at initial submission? (y/n/unknown)
		Details of data statement: Information about the data provided.

		Sept-Nov 23 sheet:
		Manuscript ID: ID of manuscript
		Compliant DOI provided at initial submission? (y/n)



## - SUB-FOLDER- Proc_b_processing
#H01_Proc V Processing_270820240-ANON.csv
sort_id: id number of submission
Manuscript.ID: Proc B Ms number [redacted]
Submission.Question.Response.y: T/F submission response [redacted]
appar_link: T/F is there a link
appar_supp: T/F is there supp matt
appar_data: T/F is there data
appar_code: Is there code
Is a link and/or supplementary materials provided?: Yes/No
How is it provided?: How is the above provided
Is data and/or code provided?: What is provided, data/code?
Checked by: Who checked the data [redacted]
Notes: Any Notes
		
		
##FOLDER - data_responses: Journal data and code policy data from DEs and final determinations w/ processing. 
#compdat_culina.csv
Journal: Journal in Culina et al 2020
Culina: Is code mandatory/encouraged or mandatory/encouraged? 
      
#compdat_culina.csv
Journal: Journal in Roche et al
policy: rating of data policy (none, strong, weak)
      
#H01_resp_aggregated_01102024.csv
Journals: Journal extracted
N_responses: Number of DE responses
Data_timing: Data timing rating
Data_timing_agree: How many DEs agree
Data_strict: Data strictness rating
Data_strict_agree: How many DEs agree
Data_clar_mean: Mean clarity for this journal
Data_clar_mode: Mode clarity for this journal
Data_clar_agree: How many DEs agree
Data_clar_Nas: Any Nas for clarity
Code_timing: Code timing rating
Code_timing_agree: How many DEs agree
Code_strict: Code strictness rating
Code_strict_agree: How many DEs agree
Code_clar_mean: Mean clarity for this journal
Code_clar_mode: Mode clarity for this journal	
Code_clar_agree: How many DEs agree
Code_clar_Nas: Any Nas for clarity

#H01_resp_processed_others-ANON.csv
MergeID: Email for merging [redacted]
Timestamp: Timing of response
Email.Address: Email address of DE [redacted]
Name.of.Reviewer: Name of DE [redacted]
Name.of.Journal: Name of journal
When.was.the.earliest.the.journal.expected.data.to.be.provided..x: Timing of data-sharing
How.strict.is.this.policy...Data.policy.: Strictness of data-sharing
Provide.the.text.that.mentions.the.above.statement..if.possible..: Data policy text.
How.clear.do.you.think.this.statement.is.: Clarity of policy rating
Where.was.the.data.policy.located...provide.a.url.to.the.specific.page..if.any.: Provide link to the policy
Any.other.comments.: Any comments
When.was.the.earliest.the.journal.expected.code.to.be.provided..x: Timing of code-sharing
How.strict.is.this.policy...Code.Policy.\: Strictness of code-sharing
Provide.the.text.that.mentions.the.above.statement..if.possible...1: Code policy text
How.clear.do.you.think.this.statement.is..1: Clarity of policy
Where.was.the.data.policy.located...provide.a.url.to.the.specific.page..if.any..1: Provide a link to the code policy
Any.other.comments..1: Any other comments

#H01_resp_processed-ANON.csv
Timestamp: Timing of response
Email.Address: Email address of DE [redacted]
Name.of.Reviewer: Name of DE [redacted]
Name.of.Journal: Name of journal
When.was.the.earliest.the.journal.expected.data.to.be.provided.: Timing of data-sharing
How.strict.is.this.policy...Data.policy.: Strictness of data-sharing
Provide.the.text.that.mentions.the.above.statement..if.possible..: Data policy text.
How.clear.do.you.think.this.statement.is.: Clarity of policy rating
Where.was.the.data.policy.located...provide.a.url.to.the.specific.page..if.any.: Provide link to the policy
Any.other.comments.: Any comments
When.was.the.earliest.the.journal.expected.code.to.be.provided: Timing of code-sharing
How.strict.is.this.policy...Code.Policy.\: Strictness of code-sharing
Provide.the.text.that.mentions.the.above.statement..if.possible...1: Code policy text
How.clear.do.you.think.this.statement.is..1: Clarity of policy
Where.was.the.data.policy.located...provide.a.url.to.the.specific.page..if.any..1: Provide a link to the code policy
Any.other.comments..1: Any other comments

#H01_responses_07022024-ANON.csv
Timestamp: Timing of response
Email Address: Email address of DE [redacted]
Name of Reviewer: Name of DE [redacted]
Name of Journal: Name of journal
When was the earliest the journal expected data to be provided.: Timing of data-sharing
How strict is this policy? [Data policy]: Strictness of data-sharing
Provide the text that mentions the above statement (if possible): Data policy text.
How clear do you think this statement is?: Clarity of policy rating
Where was the data policy located? (provide a url to the specific page; if any): Provide link to the policy
Any other comments.: Any comments
When was the earliest the journal expected code to be provided? Timng of code-sharing
How strict is this policy? [Code policy]: Strictness of code-sharing
Provide the text that mentions the above statement (if possible): Code policy text
How clear do you think this statement is?: Clarity of policy
Where was the code  policy located? (provide a url to the specific page; if any):Provide a link to the code policy
Any other comments: Any other comments

#H01_responses_07022024_corrections-ANON.csv
Timestamp: Timing of response
Email Address: Email address of DE [redacted]
Name of Reviewer: Name of DE [redacted]
Name of Journal: Name of journal
When was the earliest the journal expected data to be provided.: Timing of data-sharing
How strict is this policy? [Data policy]: Strictness of data-sharing
Provide the text that mentions the above statement (if possible): Data policy text.
How clear do you think this statement is?: Clarity of policy rating
Where was the data policy located? (provide a url to the specific page; if any): Provide link to the policy
Any other comments.: Any comments
When was the earliest the journal expected code to be provided? Timng of code-sharing
How strict is this policy? [Code policy]: Strictness of code-sharing
Provide the text that mentions the above statement (if possible): Code policy text
How clear do you think this statement is?: Clarity of policy
Where was the code  policy located? (provide a url to the specific page; if any):Provide a link to the code policy
Any other comments: Any other comments


# - SUB-FOLDER - processing_disagreements
#H01_FinalDeterms_01102024-ANON.csv
Journals: Name of journal
Publisher: Name of publisher
Publisher-Level Policy: Was there a publisher-level policy linked in the data/code policy?
2024_Update?: Was there an update in 2024
Reviewer_A: Name of reviewer A [redacted]
Reviewer_B: Name of reviewer B [redacted]
Reviewer_notes: Any notes (out of date) [redacted]
Data_timing_DE: DE timing rating
Data_timing_agree: DE agreement
Data_timing_FIN: Final rating
Data_strict_DE: DE strictness rating
Data_strict_agree: DE agreement
Data_strict_FIN: Final rating
Code_timing_DE: DE timing rating
Code_timing_agree: DE agreement
Code_timing_FIN: Final rating
Code_strict_DE: DE strictness rating
Code_strict_agree: DE agreement
Code_strict_FIN: Final rating


# - SUB-FOLDER - processing_others folder
#H01_respB_others_Data_complete-ANON.csv
Timestamp: Time of review
Email.Address: Email address of DE [redacted]
Name.of.Reviewer: Name of DE [redacted]
Name.of.Journal: Journal reviewed
When.was.the.earliest.the.journal.expected.data.to.be.provided.: When was the earliest data was provided text
Any.other.comments.: Any comments?
RECAT_When.was.the.earliest.the.journal.expected.data.to.be.provided.: Recategorisation of DE text
RECAT_by: Who by? [redacted]
RECAT_notes: Any notes? [redacted]

#H01_respB_others_Code_complete-ANON.csv
Timestamp: Time of review
Email.Address: Email address of DE [redacted]
Name.of.Reviewer: Name of DE [redacted]
Name.of.Journal: Journal reviewed
When.was.the.earliest.the.journal.expected.code.to.be.provided.: When was the earliest code was provided text
Any.other.comments.: Any comments?
RECAT_When.was.the.earliest.the.journal.expected.code.to.be.provided.: Recategorisation of DE text
RECAT_by: Who by? [redacted]
RECAT_notes: Any notes? [redacted]

 
##FOLDER - outputs_ visualisations: Figures and tables in the manuscript. All produced anbd idenfiable from included scripts.


##FOLDER - subset assignments: List of journals for each DE as well as original total list (includes duplicates + old journals)
	#H01_subset_assigments_13122023-ANONYMISED.csv
	Subset_number: What number subset did the journal appear in
        Journal: Name of journal
        Assigned_to_email: email address of DE [redacted]
        Notes: Any notes?



