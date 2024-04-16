Welcome to the repository for the code for the paper: IDyOMpy: a New Python Implementation for IDyOM, a Statistical Model of Musical Expectations. 

This paper offers a new version of the IDyOM model called IDyOMpy (https://github.com/GuiMarion/IDyOMpy) entirely re-implemented in Python and presents an innovative battery of tests to precisely compare the behavior and outcomes of our implementation to those from the original Lisp version.

This repository share the entirety of the code and data used for those tests.

dataset/ and stimuli/ contains the midi files used.
mainAnalysis/ contains the matlab code for the analyses ran.
GoldReplication contains the matlab code for the replication of the analysis in Gold, 2019. 
generateSurprise_IDyOMpy/ contains the code we used to generate the surprise for the IDyOMpy version. 
generateSurprise_IDyOM_lisp/ contains the code we used to generate the surprise for the lisp IDyOM version. 

All analyses have been ran and designed by Guilhem Marion. Benjamin Gold provided code for analyzing the data from Gold, 2019. Giovanni Di Liberto provided code and ran an analysis on data from Di Liberto, 2020 using surprises and indication from Guilhem Marion. 

Any use or inspiration of this code resulting in a publicly available presentation or article requires credit for Guilhem Marion and citation of the IDyOMpy paper.
