%let pgm=utl-altair-personal-slc-concatenating-rows-by-id-using-datasteps-and-workaround-for-sqlite-bug;

%stop_submission;

RE altair personal slc concatenating rows by id using datasteps and workaround for sqlite bug

Too long to post in a listserv, see github

github
https://github.com/rogerjdeangelis/utl-altair-personal-slc-concatenating-rows-by-id-using-datasteps-and-workaround-for-sqlite-bug

Note SLC tables can be coverted into a very large number of formats.

  TWO SOLUTIONS

      1 slc datasteps
      2 r sqlite group_concat


There is a bug in sqlite passthru in the personal slc, so we drop down to python or r.
I would provide a python solution but import/export are not supported with recent pyhton 3 versions..

community.altair.com
https://community.altair.com/discussion/27742/how-to-trap-multiple-lines-of-text-and-relate-it-to-the-1st-line-of-detail-text?tab=all#latest

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/* CONCATENATING ROWS BY ID USING            |                                                                            */
/*                                           |                                                                            */
/*      INPUT                                |      OUTPUT                                                                */
/*      =====                                |      ======                                                                */
/*                                           |                                                                            */
/*  ID     TXT      W1       W2       W3     |  SAVID             SAVWS             SAVW1    SAVW2    SAVW3               */
/*                                           |                                                                            */
/*  11    a-txt    word1    word2    word3   |    11     a-txt                      word1    word2    word3               */
/*  12    b-txt    word1    word2    word3   |    12     b-txt                      word1    word2    word3               */
/*  13    a-txt    word1    word2    word3   |    13     b-txt a-txt                word1    word2    word3               */
/*   .    b-txt                              |    14     b-txt a-txt a-txt b-txt    word1    word2    word3               */
/*  14    a-txt    word1    word2    word3   |    15     a-txt                      word1    word2    word3               */
/*   .    b-txt                              |                                                                            */
/*   .    c-txt                              |                                                                            */
/*  15    a-txt    word1    word2    word3   |                                                                            */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

Altair SLC

Obs    ID     TXT      W1       W2       W3

 1     11    a-txt    word1    word2    word3
 2     12    b-txt    word1    word2    word3
 3     13    a-txt    word1    word2    word3
 4      .    b-txt
 5     14    a-txt    word1    word2    word3
 6      .    b-txt
 7      .    c-txt
 8     15    a-txt    word1    word2    word3


data detail;
  input id txt$ w1$  w2$ w3$;
cards4;
11 a-txt word1 word2 word3
12 b-txt word1 word2 word3
13 a-txt word1 word2 word3
.  b-txt     .     .     .
14 a-txt word1 word2 word3
.  b-txt     .     .     .
.  c-txt     .     .     .
15 a-txt word1 word2 word3
;;;;
run;quit;

proc print data=detail;
run;quit;

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

2043      ODS _ALL_ CLOSE;
2044      ODS LISTING;
2045      FILENAME WBGSF 'd:\wpswrk\_TD2820/listing_images';
2046      OPTIONS DEVICE=GIF;
2047      GOPTIONS GSFNAME=WBGSF;
2048      data detail;
2049        input id txt$ w1$  w2$ w3$;
2050      cards4;

NOTE: Data set "WORK.detail" has 8 observation(s) and 5 variable(s)
NOTE: The data step took :
      real time : 0.004
      cpu time  : 0.000


2051      11 a-txt word1 word2 word3
2052      12 b-txt word1 word2 word3
2053      13 a-txt word1 word2 word3
2054      .  b-txt     .     .     .
2055      14 a-txt word1 word2 word3
2056      .  b-txt     .     .     .
2057      .  c-txt     .     .     .
2058      15 a-txt word1 word2 word3
2059      ;;;;
2060      run;quit;
2061
2062      proc print data=detail;
2063      run;quit;
NOTE: 8 observations were read from "WORK.detail"
NOTE: Procedure print step took :
      real time : 0.027
      cpu time  : 0.000


2064
2065      quit; run;
2066      ODS _ALL_ CLOSE;
2067      FILENAME WBGSF CLEAR;

/*       _            _       _            _
/ |  ___| | ___    __| | __ _| |_ __ _ ___| |_ ___ _ __  ___
| | / __| |/ __|  / _` |/ _` | __/ _` / __| __/ _ \ `_ \/ __|
| | \__ \ | (__  | (_| | (_| | || (_| \__ \ ||  __/ |_) \__ \
|_| |___/_|\___|  \__,_|\__,_|\__\__,_|___/\__\___| .__/|___/
                                                  |_|
*/

proc datasets lib=work  mt=(view data) nodetails nolist;
 delete fill roll;
run;quit;

data fill / view=fill;
  retain savid;
  set detail;
  if not missing(id) then savid=id;
run;quit;

proc print data=fill;
run;quit;

data roll;
  length savid 8 savws $255;
  retain  savws ' ' savw1 savw2 savw3;
  set fill;
  by savid;

  select;
    when (first.savid and last.savid) do;
      savw1=w1;
      savw2=w2;
      savw3=w3;
      savws=txt;
      output;
      end;
    when (last.savid) output;
    otherwise savws = catx(' ',savws,txt);
  end;
  keep sav:;
run;quit;

proc print;
run;quit;


INTERIM FILL VIEW
-----------------

Altair SLC

Obs    SAVID    ID     TXT      W1       W2       W3

 1       11     11    a-txt    word1    word2    word3
 2       12     12    b-txt    word1    word2    word3
 3       13     13    a-txt    word1    word2    word3
 4       13      .    b-txt
 5       14     14    a-txt    word1    word2    word3
 6       14      .    b-txt
 7       14      .    c-txt
 8       15     15    a-txt    word1    word2    word3

FINAL ROLL TABLE SOLUTION
-------------------------

Altair SLC

Obs    SAVID             SAVWS             SAVW1    SAVW2    SAVW3

 1       11     a-txt                      word1    word2    word3
 2       12     b-txt                      word1    word2    word3
 3       13     b-txt a-txt                word1    word2    word3
 4       14     b-txt a-txt a-txt b-txt    word1    word2    word3
 5       15     a-txt                      word1    word2    word3

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

2470      ODS _ALL_ CLOSE;
2471      ODS LISTING;
2472      FILENAME WBGSF 'd:\wpswrk\_TD2820/listing_images';
2473      OPTIONS DEVICE=GIF;
2474      GOPTIONS GSFNAME=WBGSF;
2475
2476      proc datasets lib=work  mt=(view data) nodetails nolist;
2477       delete fill roll;
2478      run;quit;
NOTE: Deleting "WORK.FILL" (memtype="VIEW")
NOTE: Deleting "WORK.ROLL" (memtype="DATA")
NOTE: Procedure datasets step took :
      real time : 0.002
      cpu time  : 0.000


2479
2480      data fill / view=fill;
2481        retain savid;
2482        set detail;
2483        if not missing(id) then savid=id;
2484      run;

NOTE: The data step took :
      real time : 0.004
      cpu time  : 0.015


2484    !     quit;
2485
2486      proc print data=fill;
2487      run;quit;
NOTE: 8 observations were read from "WORK.detail"

NOTE: The data step view execution took :
      real time : 0.002
      cpu time  : 0.000
NOTE: 8 observations were read from "WORK.detail"

NOTE: The data step view execution took :
      real time : 0.002
      cpu time  : 0.000
NOTE: 8 observations were read from "WORK.fill"
NOTE: Procedure print step took :
      real time : 0.021
      cpu time  : 0.000


2488
2489      data roll;
2490        length savid 8 savws $255;
2491        retain  savws ' ' savw1 savw2 savw3;
2492        set fill;
2493        by savid;
2494
2495        select;
2496          when (first.savid and last.savid) do;
2497            savw1=w1;
2498            savw2=w2;
2499            savw3=w3;
2500            savws=txt;
2501            output;
2502            end;
2503          when (last.savid) output;
2504          otherwise savws = catx(' ',savws,txt);
2505        end;
2506        keep sav:;
2507      run;

NOTE: 8 observations were read from "WORK.detail"

NOTE: The data step view execution took :
      real time : 0.002
      cpu time  : 0.000
NOTE: 8 observations were read from "WORK.fill"
NOTE: Data set "WORK.roll" has 5 observation(s) and 5 variable(s)
NOTE: The data step took :
      real time : 0.005
      cpu time  : 0.000


2507    !     quit;
2508
2509      proc print;
2510      run;quit;
NOTE: 5 observations were read from "WORK.roll"
NOTE: Procedure print step took :
      real time : 0.013
      cpu time  : 0.000


2511
2512      quit; run;
2513      ODS _ALL_ CLOSE;
2514      FILENAME WBGSF CLEAR;

/*___                     _ _ _
|___ \   _ __   ___  __ _| (_) |_ ___
  __) | | `__| / __|/ _` | | | __/ _ \
 / __/  | |    \__ \ (_| | | | ||  __/
|_____| |_|    |___/\__, |_|_|\__\___|
                       |_|
*/

proc datasets lib=work mt=data nolist nodetails;
 delete want fill_perm;
run;quit;

data fill_perm;
  retain savid;
  set detail;
  if not missing(id) then savid=id;
run;quit;


options set=RHOME "D:\d451";
proc r;
export data=fill_perm r=fill;
submit;
library(sqldf)
options(sqldf.dll = "d:/dll/sqlean.dll")
want<-sqldf('
   select
     max(savid)  as id
     ,max(w1) as w1
     ,max(w2) as w2
     ,max(w3) as w3
     ,group_concat(txt," ") as apntxt
  from
     fill
  group
     by savid
  ');
want
endsubmit;
import data=want r=want;
run;quit;

proc print data=want;
run;quit;


WANT TABLE
==========

Altair SLC

Obs    SAVID             SAVWS             SAVW1    SAVW2    SAVW3

 1       11     a-txt                      word1    word2    word3
 2       12     b-txt                      word1    word2    word3
 3       13     b-txt a-txt                word1    word2    word3
 4       14     b-txt a-txt a-txt b-txt    word1    word2    word3
 5       15     a-txt                      word1    word2    word3

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/
2606      ODS _ALL_ CLOSE;
2607      ODS LISTING;
2608      FILENAME WBGSF 'd:\wpswrk\_TD2820/listing_images';
2609      OPTIONS DEVICE=GIF;
2610      GOPTIONS GSFNAME=WBGSF;
2611
2612
2613      proc datasets lib=work mt=data nolist nodetails;
2614       delete want fill_perm;
2615      run;quit;
NOTE: Deleting "WORK.WANT" (memtype="DATA")
NOTE: Deleting "WORK.FILL_PERM" (memtype="DATA")
NOTE: Procedure datasets step took :
      real time : 0.001
      cpu time  : 0.000


2616
2617      data fill_perm;
2618        retain savid;
2619        set detail;
2620        if not missing(id) then savid=id;
2621      run;

NOTE: 8 observations were read from "WORK.detail"
NOTE: Data set "WORK.fill_perm" has 8 observation(s) and 6 variable(s)
NOTE: The data step took :
      real time : 0.003
      cpu time  : 0.015


2621    !     quit;
2622
2623
2624      options set=RHOME "D:\d451";
2625      proc r;
NOTE: Using R version 4.5.1 (2025-06-13 ucrt) from d:\r451
2626      export data=fill_perm r=fill;
NOTE: Creating R data frame 'fill' from data set 'WORK.fill_perm'

2627      submit;
2628      library(sqldf)
2629      options(sqldf.dll = "d:/dll/sqlean.dll")
2630      want<-sqldf('
2631         select
2632           max(savid)  as id
2633           ,max(w1) as w1
2634           ,max(w2) as w2
2635           ,max(w3) as w3
2636           ,group_concat(txt," ") as apntxt
2637        from
2638           fill
2639        group
2640           by savid
2641        ');
2642      want
2643      endsubmit;

NOTE: Submitting statements to R:

Loading required package: gsubfn
Loading required package: proto
Loading required package: RSQLite
> library(sqldf)
> options(sqldf.dll = "d:/dll/sqlean.dll")
> want<-sqldf('
+    select
+      max(savid)  as id
+      ,max(w1) as w1
+      ,max(w2) as w2
+      ,max(w3) as w3
+      ,group_concat(txt," ") as apntxt
+   from
+      fill
+   group
+      by savid
+   ');

NOTE: Processing of R statements complete

> want
2644      import data=want r=want;
NOTE: Creating data set 'WORK.want' from R data frame 'want'
NOTE: Column names modified during import of 'want'
NOTE: Data set "WORK.want" has 5 observation(s) and 5 variable(s)

2645      run;quit;
NOTE: Procedure r step took :
      real time : 1.369
      cpu time  : 0.031


2646
2647      proc print data=want;
2648      run;quit;
NOTE: 5 observations were read from "WORK.want"
NOTE: Procedure print step took :
      real time : 0.003
      cpu time  : 0.000


2649
2650
2651      quit; run;
2652      ODS _ALL_ CLOSE;
2653      FILENAME WBGSF CLEAR;

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
