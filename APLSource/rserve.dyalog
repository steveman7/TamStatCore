:Namespace RS
    ∇ r←init
      wf←⊃⎕NPARTS #.RS{⍺{0=≢⍵:⍺.SALT_Data.SourceFile ⋄ ⍵}' '~⍨⊃⍵{⍵[⍸(⊂⍺){∨/⍺⍷⍵}¨⍵]}⊃¨5176⌶⍬}'rserve.dyalog'
      #.settings←⎕JSON⊃⎕NGET wf,'settings.json'
    ∇

    ∇ r←start;a;o
      :Access public
      mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂⊃'.'⎕WG'APLVersion'
      wf←⊃⎕NPARTS #.RS{⍺{0=≢⍵:⍺.SALT_Data.SourceFile ⋄ ⍵}' '~⍨⊃⍵{⍵[⍸(⊂⍺){∨/⍺⍷⍵}¨⍵]}⊃¨5176⌶⍬}'rserve.dyalog'
      :If 0=⎕NC'#.settings' ⋄ init ⋄ :EndIf
      :If (mac⍱win)   ⍝ linux
          :If 0=≢⎕SH'pidof Rserve;exit 0'
              o←⊂'library(Rserve)'
              o,←⊂'Rserve(args="--no-save --RS-port ',(⍕#.settings.rserve.port),' --RS-conf ',wf,'Rserv.conf >~/Rserve.log")'
              (⊂o)⎕NPUT(wf,'rserve.r')1
              ⎕SH'R CMD BATCH ',wf,'rserve.r'
          :EndIf
      :ElseIf win
          :If 2>≢⎕CMD'tasklist /FI "ImageName eq Rserve.exe"'
            ⍝ a←⎕CMD'taskkill /IM Rserve.exe /F'
              o←'Rserve(args="--no-save --slave --RS-workdir ',(('\\'⎕R'\\\\')wf),' --RS-port ',(⍕#.settings.rserve.port),'")'
              a←⎕CMD(('/'⎕R'\\')'"',#.settings.r.home,'R.exe" CMD ',#.settings.rserve.home,o)'Hidden'
          :EndIf
      :ElseIf mac
          ∘ ⍝ my macbook is broken
      :EndIf
    ∇

    ∇ r←kill
      :Access public
      mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂⊃'.'⎕WG'APLVersion'
      :Trap 0
          :If bit64
              ⎕SH'kill -9 ',⍕⎕SH'pidof Rserve'
          :ElseIf win
              :If win
                  :If ⍬≢process
                      process.Kill''
                  :Else
                      a←⎕CMD'taskkill /IM Rserve.exe /F'
                  :EndIf
              :EndIf
          :EndIf
      :EndTrap
    ∇

    :class robject
        ⎕ML←1 ⋄ ⎕IO←1 ⋄ ⎕PP←34
        :Field Public data←⍬
        :field private _a←⊂''
        :field private ga←⍬

        :property keyed attributes
        :access public

            ∇ r←Get args
              :If args.IndexersSpecified
                  r←{0=≢⍵:⊂'' ⋄ ⍵[ga⍳⊃args.Indexers]}_a
              :Else
                 ⍝ r←{0=≢⍵:,⊂'' ⋄ ga{b←⍸~_a∊⊂'' ⋄ ⍺[b]{⍺ ⍵}¨⍵[b]}⍵}_a
                  r←(~_a∊⊂'')/ga
              :EndIf
            ∇

            ∇ Set args
              :If (⊂'')≡_a ⋄ _a←(⊂'')⍴⍨≢ga ⋄ :EndIf
              _a[ga⍳⊃args.Indexers]←args.NewValue
            ∇
        :endproperty

        :property default value
        :Access Public

            ∇ r←Get args
              r←{1=≢data:,⍵ ⋄ ⍵}{attributes[⊂'class']≡⊂'factor':⍉attributes[⊂'levels'][⍵]
                  ∨/({1=≡⊃⍵:⍵ ⋄ ⊃⍵}attributes[⊂'class'])∊⊂'table':⍵{~⊃attributes[⊂'dim']≡⊂'':⍵⍪⍉(⌽⊃attributes[⊂'dim'])⍴⍺ ⋄ ⍵,[0.5]⍺}⊃attributes[⊂'names']{⍺≢⊂'':⍺ ⋄ ⍵}attributes[⊂'dimnames']
                  ~attributes[⊂'dim']≡⊂'':⍉(⌽⊃attributes[⊂'dim'])⍴⍵
                  attributes[⊂'class']≡⊂'ts':(↑(⍴⍵)↑,↑{(⊂⍳⍵[3]){⍵,¨⍺}¨⍵[1],⍵[1]+⍳⌊(⍵[2]-⍵[1])}⊃attributes[⊂'tsp']),⍵
                  ∨/({1=≡⊃⍵:⍵ ⋄ ⊃⍵}attributes[⊂'class'])∊⊂'data.frame':(⊃attributes[⊂'names']){0≠⍴⍺:⍺⍪⍵ ⋄ ⍵}⍉↑{⎕IO←1 ⋄ 0::⍵ ⋄ (⊃⍵.attributes[⊂'levels'])[⍵.data]}¨{1=≡⍵:⊂⍵ ⋄ ⍵}⍵
              }data
            ∇
        :endproperty

        ∇ Make2 arg
          :Access Public
          :Implements Constructor
          ga←#.settings.r.attributes
          attributes[⊃⊃arg]←2⊃⊃arg
          data←{1=≢⍵:,↑⍵ ⋄ ⍵}2⊃arg
        ∇

        ∇ Make0
          :Access Public
          :Implements Constructor
          ga←#.settings.r.attributes
        ∇

    :endclass

    :Class Rserve
    ⍝ Interface from Dyalog APL to RServe
    ⍝ Currently asssumes existence of #.Conga
        ⎕ML←1 ⋄ ⎕IO←0 ⋄ ⎕PP←34
        :Field Public CLT←''         ⍝ Public for debugging
        :Field Private LittleEndian
        :field private error←⍬
        :field private command←⍬
        :field private type←⍬
        :field private sexp←⍬
        :field private ga←⍬
        :field private mac←0
        :field private win←0
        :field private bit64←0
        :field private process←⍬
        :field private timeout←⍬

        prop←{83=⎕dr ⍵:⊂(⍺.name,⊂⍬)[⍺.code⍳⍵] ⋄ (⍺.code,0)[⍺.name⍳⊃⍵]}

        :property keyed ERR
        :access public
            ∇ r←get args
              r←error prop args.Indexers
            ∇
        :endproperty

        :property keyed XT
        :access public
            ∇ r←get args
              r←sexp prop args.Indexers
            ∇
        :endproperty

        :property keyed CMD
        :access public
            ∇ r←get args
              r←command prop args.Indexers
            ∇
        :endproperty

        :property keyed DT
        :access public
            ∇ r←get args
              r←type prop args.Indexers
            ∇
        :endproperty

        split←{((≢⍵)⍴⍺↑1)⊂⍵} ⍝ thanks VMJ for pimping my code
        shape←{(⍺,⍨(≢⍵)÷⍺)⍴⍵}
        IntToBytes←{⎕FR←(⍺=8)⊃645 1287 ⋄ ⍺↑⎕UCS 80 ⎕DR(×⍵)×((2*(8×⍺))-1)⌊|⍵}
        b2i←{(⍺⍴256)⊥⌽⍵}
        ld←{⍵,⍨3 IntToBytes≢⍵}
        evalOut←{0,⍨DT[⊂'STRING'],ld{⍵↑⍨4×⌈(≢⍵)÷4}10,⍨⎕UCS ⍵}
        strOut←{DT[⊂'STRING'],ld{⍵↑⍨4×⌈(≢⍵)÷4}0,⍨⎕UCS ⍵}

        ∇ o←{void}eval s;b;d;dh;hdr;r;s;t;xt;z
          :Access Public
          s←{1=≡⍵:,⊂⍵ ⋄ ⍵}s
          b←{CMD[⊂{⍵:{⍵≡0:'voidEval' ⋄ 'eval'}void ⋄ 'eval'}2=⎕NC'void']{z←DRC.Send CLT(∊{4 IntToBytes ⍵}¨⍺(≢⍵)0 0) ⋄ SendWait ⍵}evalOut ⍵}¨s
          o←{1=≢⍵:⊃⍵ ⋄ ⍵}{(⍵≡,⊂⍬)∨('Err'≡3↑⍵)∨(1=≡⍵)∨1=≢∪¯1↑¨⍕¨⎕DR¨⍵:⍵ ⋄ object ⍵}¨decode¨b
          :If 0=≢o ⋄ ⎕EX'o' ⋄ :EndIf
        ∇


        ∇ o←object i;attr;b;data;in;xt
          attr←(⊂'')⍴⍨≢ga ⋄ data←⍬ ⋄ xt←⊃i ⋄ i←1↓i
          :If xt∊128+XT['ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR'] ⋄ i←⊃i ⋄ :EndIf
          :For in :In i
              :If (xt=128+XT[⊂'VECTOR'])
              :AndIf 0>≡in
              :AndIf ∨/{⍵≡⊃⊃in}¨128+XT['ARRAY_INT' 'ARRAY_DOUBLE']
                  data,←object in
                  in←⍬
              :EndIf
              :While 0≠≢in
                  :If (1<|≡in)∨(1<≢in)
                      :If ∨/b←ga∊in[1]
                          attr[⍸b]←⊂(⊃in){'row.names'≡⍵:{¯2147483648≡⊃⍵:1+⍳|1⊃⍵ ⋄ ⍵}⍺ ⋄ ⍺}1⊃in
                          in←2↓in
                      :Else
                          data,←{xt∊128+XT[⊂'ARRAY_STR']:⍵ ⋄ ⊂⍵}in ⋄ in←⍬
                      :EndIf
                  :Else
                      data,←in ⋄ in←⍬
                  :EndIf
              :EndWhile
          :EndFor
         
          o←⎕NEW robject((ga attr)data)
        ∇

        ∇ o←decode i;h;s;xt
          o←⍬ ⋄ h←16↑i ⋄ i←16↓i
          :If 1≠⊃h
              o←('Error '),⍕{⍬≡⊃⍵:2⊃h ⋄ ⍵}⊃ERR[3⊃h] ⋄ →0
          :EndIf
         
          :While 0≠≢i
              o,←(⊃i)SEXPin(4↓i)↑⍨l←3 b2i i[1 2 3] ⋄ i←(4+l)↓i
          :End
         
          :If 1=⍴o ⋄ o←⊃o ⋄ :EndIf
        ∇

        ∇ o←s set i;o;d
          :Access public
          i←{(83=⎕DR ⍵)∧0=⍴⍴i:,⍵ ⋄ ⍵}i    ⍝ atom
          o←⍬ ⋄ (s i)←s{((2>≡⍵)∧326≠⎕DR ⍵)∨((1=≢⍵)∧326=⎕DR ⍵):(,⊂⍺)(,⊂⍵) ⋄ ⍺ ⍵}i
          d←s{total←{326=⎕DR ⍵:≢⍵.data ⋄ 0}⍵ ⋄ (strOut ⍺),DT[⊂'SEXP'],ld(SEXPout ⍵)}¨i
          o←⊃¨{z←DRC.Send CLT(∊({4 IntToBytes ⍵}¨CMD[⊂'setSEXP'],(≢⍵)0 0))
              SendWait ⍵}¨d
        ∇

        ∇ o←{ty}SEXPout i;a;at;b;d;dim;dt;in;ts;ty
          :If 0=⎕NC'ty' ⋄ ty←⎕DR i ⋄ :EndIf
          :Select ty
          :Case 80
              ty←XT[⊂'ARRAY_STR']
          :CaseList 83 163 323
              ty←XT[⊂'ARRAY_INT']
          :Case 645
              ty←XT[⊂'ARRAY_DOUBLE']
          :Case 326
              :If 80≡⊃∪⎕DR¨i
                  ty←XT[⊂'ARRAY_STR']
              :EndIf
          :EndSelect
         
          :Select ty
          :CaseList XT['SYMNAME' 'ARRAY_STR']
              o←ty,ld{⍵,1⍴⍨4-4|≢⍵}∊{0,⍨⎕UCS ⍵}¨i
          :CaseList XT[⊂'ARRAY_INT']
              :If 1=≢⍴i ⍝ vector
                  o←XT[⊂'ARRAY_INT'],ld ⎕UCS 80 ⎕DR⊃0 323 ⎕DR∊{1=≢⍵:⊃⍵ ⋄ ⍵}i
              :Else     ⍝ matrix
                  dim←⌽⍴i ⋄ d←⎕UCS 80 ⎕DR⊃0 323 ⎕DR∊i
                  li←XT[⊂'SYMNAME'],1↓strOut'dim'
                  li←li,⍨XT[⊂'ARRAY_STR'],ld∊4 IntToBytes¨dim
                  li←li,⍨XT[⊂'LIST_TAG'],3 IntToBytes≢li
                  o←(128+XT[⊂'ARRAY_INT']),ld li,d
              :EndIf
          :Case 326     ⍝ robjects
              ts←∨/i.attributes[⊂'class']∊⊂'ts'
         
              :If ts
                  d←XT[⊂'ARRAY_DOUBLE']SEXPout¨{1=≡⍵:,⊂⍵ ⋄ ⍵}i.data
              :Else
                  d←SEXPout¨{1=≡⍵:,⊂⍵ ⋄ ⍵}i.data
              :EndIf
         
              at←↓{⍵,[0.5]i.attributes[⍵]}i.attributes[]
         
              :If (⊂'')≢i.attributes[⊂'row.names']
              :AndIf {⎕IO←1 ⋄ ⍵≡⍳¯1↑⍵}⊃i.attributes[⊂'row.names']
                  b←¯1↑⊃i.attributes[⊂'row.names']
                  at[{⍵⍳⊂'row.names'}0⊃¨at]←⊂(⊂'row.names'),⊂¯2147483648 b
              :EndIf
         
              a←∊{{(⊃⍵)SEXPout(1↓⍵)}¨({
                      (XT['ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR']⊃⍨323 645 80⍳⎕DR∊⍵),{
                          1=≡⍵:⊂⍵ ⋄ ⍵}⍵}1⊃⍵)(XT[⊂'SYMNAME'],⍵[0])}¨at
              :If (⍴d)<total
                  d←∊d ⋄ dt←⊃d
                  o←(128+dt),ld(4↓d),⍨XT[⊂'LIST_TAG'],ld a
              :Else
                  o←(128+XT[⊂'VECTOR']),ld(∊d),⍨XT[⊂'LIST_TAG'],ld a
              :EndIf
          :CaseList XT[⊂'ARRAY_DOUBLE']
              :If 1=≢⍴i
                  o←XT[⊂'ARRAY_DOUBLE'],ld ⎕UCS 80 ⎕DR{645≠⎕DR ⍵:⊃0 645 ⎕DR ⍵ ⋄ ⍵}∊i
              :Else
                  dim←⌽⍴i ⋄ d←⎕UCS 80 ⎕DR∊i
                  li←XT[⊂'SYMNAME'],1↓strOut'dim'
                  li←li,⍨XT[⊂'ARRAY_INT'],ld∊4 IntToBytes¨dim
                  li←li,⍨XT[⊂'LIST_TAG'],3 IntToBytes≢li
                  o←(128+XT[⊂'ARRAY_DOUBLE']),ld li,d
              :End
          :Else
              ∘
          :EndSelect
        ∇

        ∇ o←t SEXPin i;a;b;class;d;dh;dim;dt;hdr;ii;in;levels;names;out;row;s;save;st;ty;xt;bb
          d←⍬ ⋄ o←t{(⍺≡10)∧0≡+/⍵:⎕NULL ⋄ ⍬}i
          :While (0≠≢i)∧(0≠+/i)
              xt←⊃i ⋄ s←(3 b2i i[1 2 3]) ⋄ i←4↓i ⋄ ii←s↑i
              :If 0=≢i ⋄ o←1 ⋄ →0 ⋄ :EndIf
              :Select xt
              :Case 0
              :Case XT[⊂'VECTOR']
                  d←⊃xt SEXPin ii
              :Case XT[⊂'SYMNAME']
                  d←⎕UCS{⍵/⍨(~⍵∊1)∧⌽∨\~0∊⍨⌽⍵}ii
              :CaseList XT['LIST_TAG' 'LANG_TAG']
                  d←xt SEXPin ii
                  :If t∊128+XT['ARRAY_INT' 'ARRAY_DOUBLE']
                      (a b)←(t-160)⊃(323 4)(645 8)
                      d←d(∊a ⎕DR ⎕UCS b shape s↓i) ⋄ s←≢i
                  :ElseIf t∊128+XT[⊂'ARRAY_STR']
                      d←d(⎕UCS¨{⍵⊆⍨~⍵∊0}{⍵↓⍨-1+0⍳⍨⌽⍵}s↓i) ⋄ s←≢i
                  :EndIf
              :Case XT[⊂'CLOS']
                  d←xt SEXPin ii
              :Case XT[⊂'LANG_NOTAG']
                  d←xt SEXPin ii
              :CaseList XT[⊂'UNKNOWN'],128+XT[⊂'UNKNOWN']
                  →0
              :Case XT[⊂'ARRAY_INT']
                  d←∊323 ⎕DR ⎕UCS 4 shape ii
              :Case XT[⊂'ARRAY_DOUBLE']
                  :Trap 11
                      a←8 shape ii
                      d←∊645 ⎕DR ⎕UCS a
                  :Else
                      b←(0 0 0 0 0 0 240 127)⍷a       ⍝ infinity
                      b∨←(0 0 0 0 0 0 240 255)⍷a      ⍝ -infinity
                      b∨←(0 0 0 0 0 0 248 127)⍷a      ⍝ NaN
                      b∨←(162 7 0 0 0 0 240 127)⍷a    ⍝ NA_real_
                      bb←∨/b
                      d←∊645 ⎕DR ⎕UCS(~bb)⌿a
                      d←(~bb)\d ⋄ (bb/d)←⎕NULL
                  :End
              :Case XT[⊂'ARRAY_STR']
                  d←{1=≢⍵:⊃⍵ ⋄ ⍵}⎕UCS¨{⍵⊆⍨~⍵∊0}{⍵↓⍨-1+0⍳⍨⌽⍵}ii
              :Case XT[⊂'ARRAY_BOOL']      ⍝ logical
                  d←4↓ii~255 ⋄ ((d∊2)/d)←⎕NULL     ⍝ NA
              :Case XT[⊂'ARRAY_CPLX']
                  :Trap 11
                      a←8 shape ii
                      d←∊645 ⎕DR ⎕UCS a
                  :Else
                      b←(0 0 0 0 0 0 240 127)⍷a       ⍝ infinity
                      b∨←(0 0 0 0 0 0 240 255)⍷a      ⍝ -infinity
                      b∨←(0 0 0 0 0 0 248 127)⍷a      ⍝ NaN
                      b∨←(162 7 0 0 0 0 240 127)⍷a    ⍝ NA_real_/NA_complex_
                      bb←∨/b
                      d←{a←2÷⍨≢⍵ ⋄ (a↑⍵)+(a↓⍵)×¯1*0.5}∊645 ⎕DR ⎕UCS(~bb)⌿a
                      d←(~bb)\d ⋄ (bb/d)←⎕NULL
                  :End
              :Case 128 ⋄ →0
              :CaseList 128+XT['S4' 'VECTOR' 'ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR']
                  d←xt,(xt SEXPin ii)
              :Else
                  ∘
              :EndSelect
         
              :If 0≠≢d ⋄ o,←⊂d ⋄ i←s↓i ⋄ :EndIf
          :EndWhile
        ∇
        ∇ o←SendWait d;z;done;length
          :If 0≠0⊃z←DRC.Send CLT d
              ('Send failed: ',,⍕z)⎕SIGNAL 11
          :EndIf
         
          o←⍬ ⋄ done←0 ⋄ length←¯1
          :Repeat
              :If 0=0⊃z←DRC.Wait CLT timeout
                  d←3⊃z
                  :If length=¯1 ⍝ First block
                      length←16+4 b2i d[4+⍳4]
                      o←d
                  :Else
                      o,←d
                  :EndIf
                  done←length≤⍴o
              :Else
                  done←1
                  o←z
              :EndIf
          :Until done
      ⍝ KSL 1.01
        ∇

        ∇ Make;a;b;f;h;out;p;r;rc;step;z;si;c;wf
          :Access public
          :Implements constructor
          :If 0=⎕NC'#.settings'
              RS.init
          :EndIf
          error←#.settings.r.error ⋄ command←#.settings.r.command
          sexp←#.settings.r.sexp ⋄ type←#.settings.r.type
          ga←#.settings.r.attributes
          timeout←#.settings.rserve.timeout
         
          :If 0=⎕NC'RS.DRC'
              :If 0=⎕NC'#.Conga' ⋄ 'Conga'#.⎕CY'conga' ⋄ :EndIf
              DRC←#.Conga.Init''
          :EndIf
         
          :If 0=0⊃z←DRC.Clt''#.settings.rserve.address #.settings.rserve.port'Raw'⊣step←'Connection'
              CLT←1⊃z
          :AndIf 0=0⊃z←DRC.Wait CLT⊣step←'Wait for confirmation'
          :AndIf 32=≢h←⎕UCS 3⊃z⊣step←'Check R header'
          :AndIf 'Rsrv'≡4↑h⊣step←'Check R header for protocol'
          :AndIf 'QAP1'≡h[8+⍳4]⊣step←'Check R header for transfer protocol'
        ⍝ Then you should check authentication protocol
          :Else
              ('Failed at step ',step,': ',,⍕z)⎕SIGNAL 11
          :EndIf
        ∇

        ∇ UnMake;a
          :Implements destructor
          :Trap 0 ⍝ Ignore errors in teardown
              :If 0≠≢DRC.Names'' ⋄ {}DRC.Close¨DRC.Names'' ⋄ :EndIf
          :EndTrap
        ∇
    :endclass
:EndNamespace
