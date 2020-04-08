<TeXmacs|1.99.12>

<project|polkadot_host_spec.tm>

<style|<tuple|book|algorithmacs-style>>

<\body>
  <chapter|Consensus><label|chap-consensu>

  Consensus in the Polkadot Host is achieved during the execution of two
  different procedures. The first procedure is block production and the
  second is finality. The Polkadot Host must run these procedures, if and
  only if it is running on a validator node.

  <section|Common Consensus Structures>

  <subsection|Consensus Authority Set><label|sect-authority-set>

  Because Polkadot is a proof-of-stake protocol, each of its consensus engine
  has its own set of nodes, represented by known public keys which have the
  authority to influence the protocol in pre-defined ways explained in this
  section. In order to verifiy the validity of each block, Polkadot node must
  track the current list of authorities for that block as formalised in
  Definition <reference|defn-authority-list>

  <\definition>
    <label|defn-authority-list>The <strong|authority list> of block <math|B>
    for consensus engine <math|C> noted as
    <strong|<math|Auth<rsub|C><around*|(|B|)>>> \ is an array of pairs of
    type:

    <\equation*>
      <around*|(|Pk<rsub|A>,W<rsub|A>|)>
    </equation*>

    <math|P<rsub|A>> is the session public key of authority A as defined in
    Definition <reference|defn-session-key>. And <math|W<rsub|A>> is a
    <verbatim|u64> value, indicating the authority weight which is set to
    equal to 1. The value of <math|Auth<rsub|C><around*|(|B|)>> is part of
    the Polkadot state. The value for <math|Auth<rsub|C><around*|(|B<rsub|0>|)>>
    is set in the genesis state (see Section <reference|sect-genesis-block>)
    and can be retrieved using a runtime entery corresponding to consensus
    engine <math|C>.
  </definition>

  Note that in Polkadot, all authorities have the weight equal to 1. The
  weight <math|W<rsub|A>> in Definition <reference|defn-authority-list>
  exists for potential improvements in the protocol and could have a use-case
  in the future.

  <subsection|Runtime-to-Consensus Engine
  Message><label|sect-consensus-message-digest>

  The authority lists (see Definition <reference|defn-authority-list>) is
  part of Polkadot state and the Runtime has the authority of updating the
  lists in the course of state transitions. The runtime inform the
  corresponding consensus engine about the changes in the authority set by
  means of setting a consensus message digest item as defined in Definition
  <reference|defn-consensus-message-digest>, in the block header of block
  <math|B> during which course of exectution the transition in the authority
  set has occured.\ 

  <\definition>
    <label|defn-consensus-message-digest> Consensus Message is digest item of
    type 4 as defined in Definition <reference|defn-digest> and consists of
    the pair:

    <\equation*>
      <around*|(|E<rsub|id>,CM|)>
    </equation*>

    Where <math|E<rsub|id>\<in\>\<bbb-B\><rsub|4>> is the consensus engine
    unique identifier which can hold the following possible values

    \;

    <\equation*>
      E<rsub|id>\<assign\><around*|{|<tabular*|<tformat|<table|<row|<cell|<rprime|''>BABE<rprime|''>>|<cell|>|<cell|For
      messages related to BABE protocol refered to as
      E<rsub|id><around*|(|BABE|)>>>|<row|<cell|<rprime|''>FRNK<rprime|''>>|<cell|>|<cell|For
      messages related to GRANDPA protocol referred to as
      E<rsub|id><around*|(|FRNK|)>>>>>>|\<nobracket\>>
    </equation*>

    and CM is of varying data type which can hold one of the type described
    in Table <reference|tabl-consensus-messages>:

    <\center>
      <\small-table|<tabular|<tformat|<cwith|1|1|1|-1|cell-tborder|0ln>|<cwith|1|1|1|-1|cell-bborder|1ln>|<cwith|2|2|1|-1|cell-tborder|1ln>|<cwith|1|1|1|1|cell-tborder|0ln>|<cwith|1|-1|1|1|cell-lborder|0ln>|<cwith|1|1|2|2|cell-tborder|0ln>|<cwith|1|-1|2|2|cell-lborder|1ln>|<cwith|1|-1|1|1|cell-rborder|1ln>|<cwith|1|-1|2|2|cell-rborder|1ln>|<table|<row|<cell|<strong|Type
      Id>>|<cell|<strong|Type>>|<cell|<strong|Sub-components>>>|<row|<cell|1>|<cell|Scheduled
      Change>|<cell|<math|<around*|(|Auth<rsub|C>,N<rsub|delay>|)>>>>|<row|<cell|2>|<cell|ForcedChange>|<cell|<math|<around*|(|Auth<rsub|C>,N<rsub|delay>|)>>>>|<row|<cell|3>|<cell|On
      Disabled>|<cell|<math|Auth<rsub|ID>>>>|<row|<cell|4>|<cell|Pause>|<cell|<math|N<rsub|delay>>>>|<row|<cell|5>|<cell|Resume>|<cell|N<math|<rsub|delay>>>>>>>>
        <label|tabl-consensus-messages>The consensus digest item for GRANDPA
        authorities
      </small-table>
    </center>

    Where:

    <\itemize-minus>
      <item>Auth<math|<rsub|C>> is the authority list defined in Definition
      <reference|defn-authority-list>.

      <item><math|N<rsub|delay>\<assign\><around*|\|||\<nobracket\>>><name|SubChain><math|<around*|(|B,B<rprime|'>|)><around*|\|||\<nobracket\>>>
      is an unsigned 32 bit integer indicating the length of the subchain
      starting at <math|B>, the block containing the consensus message in its
      header digest and ending when it reaches <math|N<rsub|delay>> length as
      a path graph. The last block in that subchain, <math|B<rprime|'>>,
      depending on the message type, is either finalized or imported (and
      therefore validated by the block production consensus engine according
      to Algorithm <reference|algo-import-and-validate-block>. see below for
      details).

      <item><math|Auth<rsub|ID>> is an unsigned 64 bit integer pointing to an
      individual authority in the current authority list.
    </itemize-minus>
  </definition>

  The Polkadot Host should inspect the digest header of each block and
  delegates consesus messages to their consensus engines. Consensus engine
  should react based on the type of consensus messages they receives as
  follows:

  <\itemize-minus>
    <item><strong|Scheduled Change>: Schedule an authority set change after
    the given delay of <math|N<rsub|delay>\<assign\><around*|\|||\<nobracket\>>><name|SubChain><math|<around*|(|B,B<rprime|'>|)><around*|\|||\<nobracket\>>>
    where <math|B<rprime|'>> in the definition of <math|N<rsub|delay>>, is a
    block <em|finalized> by the finality consensus engine. The earliest
    digest of this type in a single block will be respected. No change should
    be scheduled if one is already and the delay has not passed completely.
    If such an inconsitency occures, the scheduled change should be ignored.

    <item><strong|Forced Change>: Force an authority set change after the
    given delay of <math|N<rsub|delay>\<assign\><around*|\|||\<nobracket\>>><name|SubChain><math|<around*|(|B,B<rprime|'>|)><around*|\|||\<nobracket\>>>
    where <math|B<rprime|'>> in the definition of <math|N<rsub|delay>>, is an
    <em|imported> block which has been validated by the block production
    conensus engine. Hence, the authority change set is valid for every
    subchain which contains <em|B> and where the delay has been exceeded. If
    one or more blocks gets finalized before the change takes effect, the
    authority set change should be disregarded. The earliest digest of this
    type in a single block will be respected. No change should be scheduled
    if one is already and the delay has not passed completely. If such an
    inconsitency occures, the scheduled change should be ignored.

    <item><strong|On Disabled>: An index to the individual authority in the
    current authority list that should be immediately disabled until the next
    authority set change. When an authority gets disabled, the node should
    stop performing any authority functionality from that authority,
    including authoring blocks and casting GRANDPA votes for finalization.
    Similarly, other nodes should ignore all messages from the indicated
    authority which pretain to their authority role.\ 

    <item><strong|Pause>: A signal to pause the current authority set after
    the given delay of <math|N<rsub|delay>\<assign\><around*|\|||\<nobracket\>>><name|SubChain><math|<around*|(|B,B<rprime|'>|)><around*|\|||\<nobracket\>>>
    where <math|B<rprime|'>> in the definition of <math|N<rsub|delay>>, is a
    block <em|finalized> by the finality consensus engine. After finalizing
    block <math|B<rprime|'>>, the authorities should stop voting.

    <item><strong|Resume>: A signal to resume the current authority set after
    the given delay of <math|N<rsub|delay>\<assign\><around*|\|||\<nobracket\>>><name|SubChain><math|<around*|(|B,B<rprime|'>|)><around*|\|||\<nobracket\>>>
    where <math|B<rprime|'>> in the definition of <math|N<rsub|delay>>, is an
    <em|imported> block and validated by the block production consensus
    engine. After authoring the block <math|B<rprime|'>>, the authorities
    should resume voting.
  </itemize-minus>

  The active GRANDPA authorities can only vote for blocks that occured after
  the finalized block in which they were selected. Any votes for blocks
  before the <verbatim|Scheduled Change> came into effect get rejected.

  <section|Block Production><label|sect-babe><label|sect-block-production>

  The Polkadot Host uses BABE protocol <cite|w3f_research_group_blind_2019>
  for block production. It is designed based on Ouroboros praos
  <cite|david_ouroboros_2018>. BABE execution happens in sequential
  non-overlapping phases known as an <strong|<em|epoch>>. Each epoch on its
  turn is divided into a predefined number of slots. All slots in each epoch
  are sequentially indexed starting from 0. At the beginning of each epoch,
  the BABE node needs to run Algorithm <reference|algo-block-production-lottery>
  to find out in which slots it should produce a block and gossip to the
  other block producers. In turn, the block producer node should keep a copy
  of the block tree and grow it as it receives valid blocks from other block
  producers. A block producer prunes the tree in parallel by eliminating
  branches which do not include the most recent finalized blocks according to
  Definition <reference|defn-pruned-tree>.

  <subsection|Preliminaries>

  <\definition>
    A <strong|block producer>, noted by <math|\<cal-P\><rsub|j>>, is a node
    running the Polkadot Host which is authorized to keep a transaction queue
    and which gets a turn in producing blocks.
  </definition>

  <\definition>
    <strong|Block authoring session key pair
    <math|<around*|(|sk<rsup|s><rsub|j>,pk<rsup|s><rsub|j>|)>>> is an SR25519
    key pair which the block producer <math|\<cal-P\><rsub|j>> signs by their
    account key (see Definition <reference|defn-account-key>) and is used to
    sign the produced block as well as to compute its lottery values in
    Algorithm <reference|algo-block-production-lottery>.\ 
  </definition>

  <\definition>
    <label|defn-epoch-slot>A block production <strong|epoch>, formally
    referred to as <math|\<cal-E\>>, is a period with pre-known starting time
    and fixed length during which the set of block producers stays constant.
    Epochs are indexed sequentially, and we refer to the <math|n<rsup|th>>
    epoch since genesis by <math|\<cal-E\><rsub|n>>. Each epoch is divided
    into <math|>equal length periods known as block production
    <strong|slots>, sequentially indexed in each epoch. The index of each
    slot is called <strong|slot number>. The equal length duration of each
    slot is called the <strong|slot duration> and indicated by
    <math|\<cal-T\>>. Each slot is awarded to a subset of block producers
    during which they are allowed to generate a block.
  </definition>

  <\notation>
    <label|note-slot>We refer to the number of slots in epoch
    <math|\<cal-E\><rsub|n>> by <math|sc<rsub|n>>. <math|sc<rsub|n>> is set
    to the <verbatim|duration> field in the returned data from the call of
    the Runtime entry <verbatim|BabeApi_configuration> (see
    <reference|sect-rte-babeapi-epoch>) at the beginning of each epoch. For a
    given block <math|B>, we use the notation <strong|<math|s<rsub|B>>> to
    refer to the slot during which <math|B> has been produced. Conversely,
    for slot <math|s>, <math|\<cal-B\><rsub|s>> is the set of Blocks
    generated at slot <math|s>.
  </notation>

  Definition <reference|defn-epoch-subchain> provides an iterator over the
  blocks produced during an specific epoch.

  <\definition>
    <label|defn-epoch-subchain> By <name|SubChain(<math|\<cal-E\><rsub|n>>)>
    for epoch <math|\<cal-E\><rsub|n>>, we refer to the path graph of
    <math|BT> which contains all the blocks generated during the slots of
    epoch <math|\<cal-E\><rsub|n>>. When there is more than one block
    generated at a slot, we choose the one which is also on
    <name|Longest-Chain(<math|BT>)>.
  </definition>

  <subsection|Block Production Lottery>

  <\definition>
    <label|defn-winning-threshold><strong|Winning threshold> denoted by
    <strong|<math|\<tau\><rsub|\<varepsilon\><rsub|n>>>> is the threshold
    which is used alongside with the result of Algorirthm
    <reference|algo-block-production-lottery> to decide if a block producer
    is the winner of a specific slot. <math|\<tau\><rsub|\<varepsilon\><rsub|n>>>
    is calculated \ as follows:

    <\equation*>
      \<tau\><rsub|\<varepsilon\><rsub|n>>\<assign\>1-<around*|(|1-c|)><rsup|<frac|1|<around*|\||AuthorityDirectory<rsup|\<cal-E\><rsub|n>>|\|>>>
    </equation*>

    where <math|AuthorityDirectory<rsup|\<cal-E\><rsub|n>>> is the set of
    BABE authorities for epoch <math|\<varepsilon\><rsub|n>> and
    <math|c=<frac|c<rsub|nominator>|c<rsub|denominator>>>. The pair
    <math|<around*|(|c<rsub|nominator>,c<rsub|denominator>|)>> can be
    retrieve part of the data returned by a call into runtime entry
    <verbatim|BabeApi_configuration>.
  </definition>

  \ A block producer aiming to produce a block during
  <math|\<cal-E\><rsub|n>> should run Algorithm
  <reference|algo-block-production-lottery> to identify the slots it is
  awarded. These are the slots during which the block producer is allowed to
  build a block. The <math|sk> is the block producer lottery secret key and
  <math|n> is the index of epoch for whose slots the block producer is
  running the lottery.

  <\algorithm>
    <label|algo-block-production-lottery><name|Block-production-lottery>(<math|sk:>session
    secret key of the producer,

    <math|n:>epoch index)
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|r\<leftarrow\>><name|Epoch-Randomness<math|<around*|(|n|)>>>
      </state>

      <\state>
        <FOR-TO|<math|i\<assign\>1>|<math|sc<rsub|n>>>
      </state>

      <\state>
        <math|<around*|(|\<pi\>,d|)>\<leftarrow\>><em|<name|VRF>>(<math|r,i,sk>)
      </state>

      <\state>
        <math|A<around*|[|i|]>\<leftarrow\><around*|(|d,\<pi\>|)>><END>
      </state>

      <\state>
        <\RETURN>
          A
        </RETURN>
      </state>
    </algorithmic>
  </algorithm>

  For any slot <math|i> in epoch <math|n> where <math|d\<less\>\<tau\>>, the
  block producer is required to produce a block. For the definitions of
  <name|Epoch-Randomness<math|>> and <em|<name|VRF>> functions, see Algorithm
  <reference|algo-epoch-randomness> and Section <reference|sect-vrf>
  respectively.

  <subsection|Slot Number Calculation>

  It is essential for a block producer to calculate and validate the slot
  number at a certain point in time. Slots are dividing the time continuum in
  an overlapping interval. At a given time, the block producer should be able
  to determine the set of slots which can be associated to a valid block
  generated at that time. We formalize the notion of validity in the
  following definitions:

  <\definition>
    <label|slot-time-cal-tail>The <strong|slot tail>, formally referred to by
    <math|SlTl> represents the number of on-chain blocks that are used to
    estimate the slot time of a given slot. This number is set to be 1200.
  </definition>

  Algorithm <reference|algo-slot-time> determines the slot time for a future
  slot based on the <em|block arrival time> associated with blocks in the
  slot tail defined in Definition <reference|defn-block-time>.

  <\definition>
    <label|defn-block-time>The <strong|block arrival time> of block <math|B>
    for node <math|j> formally represented by
    <strong|<math|T<rsup|j><rsub|B>>> is the local time of<verbatim|> node
    <math|j> when node <math|j> has received the block <math|B> for the first
    time. If the node <math|j> itself is the producer of <math|B>,
    <math|T<rsub|B><rsup|j>> is set equal to the time that the block is
    produced. The index <math|j> in <math|T<rsup|j><rsub|B>> notation may be
    dropped and B's arrival time is referred to by <math|T<rsub|B>> when
    there is no ambiguity about the underlying node.
  </definition>

  In addition to the arrival time of block <math|B>, the block producer also
  needs to know how many slots have passed since the arrival of <math|B>.
  This value is formalized in Definition <reference|defn-slot-offset>.

  <\definition>
    <label|defn-slot-offset>Let <math|s<rsub|i>> and <math|s<rsub|j>> be two
    slots belonging to epochs <math|\<cal-E\><rsub|k>> and
    <math|\<cal-E\><rsub|l>>. By <name|Slot-Offset><math|<around*|(|s<rsub|i>,s<rsub|j>|)>>
    we refer to the function whose value is equal to the number of slots
    between <math|s<rsub|i>> and <math|s<rsub|j>> (counting <math|s<rsub|j>>)
    on time continuum. As such, we have <name|Slot-Offset><math|<around*|(|s<rsub|i>,s<rsub|i>|)>=0>.
  </definition>

  <\algorithm>
    <label|algo-slot-time><name|Slot-Time>(<math|s>: the slot number of the
    slot whose time needs to be determined)
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|T<rsub|s>\<leftarrow\><around*|{||}>>
      </state>

      <\state>
        <math|B<rsub|d>\<leftarrow\>><name|Deepest-Leaf(<math|BT>)>
      </state>

      <\state>
        <FOR-IN|<math|B<rsub|i>>|<name|SubChain>(<math|B<rsub|H<rsub|n><around*|(|B<rsub|d>|)>-SITL>>,
        <math|B<rsub|d>>)>
      </state>

      <\state>
        <name|<math|s<rsub|t><rsup|B<rsub|i>>\<leftarrow\>T<rsup|><rsub|B<rsub|i>>>+Slot-Offset(<math|s<rsub|B<rsub|i>>,s>)<math|\<times\>\<cal-T\><rsub|>>>
      </state>

      <\state>
        <math|T<rsub|s>\<leftarrow\>T<rsub|s>\<cup\>><math|s<rsub|t><rsup|B<rsub|i>>><END>
      </state>

      <\state>
        <\RETURN>
          Median(<math|T<rsub|s>>)
        </RETURN>
      </state>
    </algorithmic>
  </algorithm>

  \ <math|\<cal-T\>> is the slot duration defined in Definition
  <reference|defn-epoch-slot>.

  <subsection|Block Production>

  At each epoch, each block producer should run Algorithm
  <reference|algo-block-production> to produce blocks during the slots it has
  been awarded during that epoch. The produced block needs to carry <em|BABE
  header> as well as the <em|block signature> \ as Pre-Runtime and Seal
  digest items defined in Definition <reference|defn-babe-header> and
  <reference|defn-block-signature> respectively.

  <\definition>
    The <label|defn-babe-header><strong|BABE Header> of block B, referred to
    formally by <strong|<math|H<rsub|BABE><around*|(|B|)>>> is a tuple that
    consists of the following components:

    <\equation*>
      <around*|(|d,\<pi\>,j,s|)>
    </equation*>

    in which:

    <\with|par-mode|center>
      <tabular|<tformat|<cwith|1|-1|1|1|cell-halign|r>|<cwith|3|3|1|1|cell-halign|r>|<table|<row|<cell|<math|\<pi\>,d>:>|<cell|are
      the results of the block lottery for slot s.
      >>|<row|<cell|<math|j>:>|<cell|is index of the block producer producing
      block in the current authority directory of current epoch.
      >>|<row|<cell|s:>|<cell|is the slot at which the block is
      produced.>>>>>

      \;
    </with>

    \;

    <math|H<rsub|BABE><around*|(|B|)>> must be included as a diegst item of
    Pre-Runtime type in the header digest <math|H<rsub|d><around*|(|B|)>> as
    defined in Definition <reference|defn-digest>.\ 
  </definition>

  <\definition>
    <label|defn-block-signature><label|defn-babe-seal>The <strong|Block
    Signature> noted by <math|S<rsub|B>> is computed as

    <\equation*>
      Sig<rsub|SR25519,sk<rsup|s><rsub|j>><around*|(|H<rsub|h><around*|(|B|)>|)>
    </equation*>

    \ <math|S<rsub|B>> should be included in <math|H<rsub|d><around*|(|B|)>>
    as the Seal digest item according to Definition <reference|defn-digest>
    of value:

    <\equation*>
      <around*|(|E<rsub|id><around*|(|BABE|)>,S<rsub|B>|)>
    </equation*>

    in which, <math|E<rsub|id><around*|(|BABE|)>> is the BABE consensus
    engine unique identifier defined in Section
    <reference|sect-msg-consensus>. The Seal digest item is referred to as
    <strong|BABE Seal>.

    \;
  </definition>

  <\algorithm|<label|algo-block-production><verbatim|><name|Invoke-Block-Authoring>(<math|sk>,
  pk, <math|n>, <math|BT:Current Block Tree>)>
    <\algorithmic>
      <\state>
        <math|A\<leftarrow\>><name|Block-production-lottery(<math|sk>,
        <math|n>)>
      </state>

      <\state>
        <FOR-TO|<\math>
          s\<leftarrow\>1
        </math>|<math|sc<rsub|n>>>
      </state>

      <\state>
        <name|Wait>(<strong|until> <name|Slot-Time>(s))
      </state>

      <\state>
        <math|<around*|(|d,\<pi\>|)>\<leftarrow\>A<around*|[|s|]>>
      </state>

      <\state>
        <\IF>
          <math|d\<less\>\<tau\>>
        </IF>
      </state>

      <\state>
        <math|C<rsub|Best>\<leftarrow\>><name|Longest-Chain>(BT)
      </state>

      <\state>
        <name|<math|B<rsub|s>\<leftarrow\>>Build-Block(<math|C<rsub|Best>>)>
      </state>

      <\state>
        <name|Add-Digest-Item>(<math|B<rsub|s>>,Pre-Runtime,<math|E<rsub|id><around*|(|BABE|)>,H<rsub|BABE><around*|(|B<rsub|s>|)>>)
      </state>

      <\state>
        <name|Add-Digest-Item>(<math|B<rsub|s>>,Seal,<math|S<rsub|B>>)
      </state>

      <\state>
        <name|Broadcast-Block>(<math|B<rsub|s>>)
      </state>
    </algorithmic>
  </algorithm>

  <name|Add-Digest-Item> appends a digest item to the end of the header
  digest <math|H<rsub|d><around*|(|B|)>> according to Definition
  <reference|defn-digest>.

  <subsection|Epoch Randomness><label|sect-epoch-randomness>

  At the end of epoch <math|\<cal-E\><rsub|n>>, each block producer is able
  to compute the randomness seed it needs in order to participate in the
  block production lottery in epoch <math|\<cal-E\><rsub|n+2>>. For epoch 0
  and 1, the randomness seed is provided in the genesis state. The
  computation of the seed is described in Algorithm
  <reference|algo-epoch-randomness> which uses the concept of epoch subchain
  described in Definition <reference|defn-epoch-subchain>.

  <\algorithm>
    <label|algo-epoch-randomness><name|Epoch-Randomness>(<math|n\<gtr\>2:>epoch
    index)
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|\<rho\>\<leftarrow\>\<phi\>>
      </state>

      <\state>
        <FOR-IN|<math|B>|><em|<name|SubChain(<math|\<cal-E\><rsub|n-2>>)>>
      </state>

      <\state>
        <math|\<rho\>\<leftarrow\>\<rho\><around*|\|||\|>d<rsub|B>><END>
      </state>

      <\state>
        <\RETURN>
          Blake2b(<name|Epoch-Randomness>(<math|n-1>)\|\|<math|n>\|\|<math|\<rho\>>)
        </RETURN>
      </state>
    </algorithmic>
  </algorithm>

  In which value <math|d<rsub|B>> is the VRF output computed for slot
  <math|s<rsub|B>> by running Algorithm <reference|algo-block-production-lottery>.

  \;

  <subsection|Verifying Authorship Right><label|sect-verifying-authorship>

  When a Polkadot node receives a produced block, it needs to verify if the
  block producer was entitled to produce the block in the given slot by
  running Algorithm <reference|algo-verify-authorship-right> where:

  <\itemize-minus>
    <item>T<math|<rsub|B>> is <math|B>'s arrival time defined in Definition
    <reference|defn-block-time>.

    <item><math|H<rsub|d><around*|(|B|)>> is the digest sub-component of
    <math|Head<around*|(|B|)>> defined in Definitions
    <reference|defn-block-header> and <reference|defn-digest>.

    <item>The Seal <math|D<rsub|s>> is the last element in the digest array
    <math|H<rsub|d><around*|(|B|)>> as defined in Definition
    <reference|defn-digest>.

    <item><name|Seal-Id> is the type index showing that a digest item of
    variable type is of <em|Seal> type (See Definitions
    <reference|defn-scale-variable-type> and <reference|defn-digest>)

    <item><math|AuthorityDirectory<rsup|\<cal-E\><rsub|c>>> is the set of
    Authority ID for block producers of epoch <math|\<cal-E\><rsub|c>>.

    <item><name|verify-Slot-Winner> is defined in Algorithm
    <reference|algo-verify-slot-winner>.
  </itemize-minus>

  <\algorithm>
    <label|algo-verify-authorship-right><name|Verify-Authorship-Right>(<math|Head<rsub|s><around*|(|B|)>>:
    The header of the block being verified)\ 
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|s\<leftarrow\>><name|Slot-Number-At-Given-Time>(<math|T<rsub|B<rsub|>>>)
      </state>

      <\state>
        <math|\<cal-E\><rsub|c>\<leftarrow\>><name|Current-Epoch>()
      </state>

      <\state>
        <math|<around*|(|D<rsub|1>,\<ldots\>,D<rsub|length<around*|(|H<rsub|d><around*|(|B|)>|)>>|)>\<leftarrow\>H<rsub|d><around*|(|B|)>>
      </state>

      <\state>
        <math|D<rsub|s>\<leftarrow\>><math|D<rsub|length<around*|(|H<rsub|d><around*|(|B|)>|)>>>
      </state>

      <\state>
        <math|H<rsub|d><around*|(|B|)>\<leftarrow\><around*|(|D<rsub|1>,\<ldots\>,D<rsub|length<around*|(|H<rsub|d><around*|(|B|)>|)>-1>|)>>
        //remove the seal from the digest
      </state>

      <\state>
        (<math|id,Sig<rsub|B>>)<math|\<leftarrow\>Dec<rsub|SC><around*|(|D<rsub|s>|)>>
      </state>

      <\state>
        <\IF>
          <math|id\<neq\>><name|Seal-Id>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PSeal missing\Q<END>
        </ERROR>
      </state>

      <\state>
        AuthorID <math|\<leftarrow\>AuthorityDirectory<rsup|\<cal-E\><rsub|c>><around*|[|H<rsub|BABE><around*|(|B|)>.SingerIndex|]>>
      </state>

      <\state>
        <name|Verify-Signature>(<math|AuthorID,H<rsub|h><around*|(|B|)>,Sig<rsub|B>>)
      </state>

      <\state>
        <\IF>
          <math|\<exists\>B<rprime|'>\<in\>BT:H<rsub|h><around*|(|B|)>\<neq\>H<rsub|h><around*|(|B|)>>
          <strong|and> <math|s<rsub|B>=s<rprime|'><rsub|B>> <strong|and>
          <math|><math|SignerIndex<rsub|B>=SignerIndex<rsub|B<rprime|'>>>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PBlock producer is equivocating\Q<END>
        </ERROR>
      </state>

      <\state>
        <name|Verify-Slot-Winner>(<math|<around*|(|d<rsub|B>,\<pi\><rsub|B>|)>,s>,AuthorID)
      </state>
    </algorithmic>
  </algorithm>

  Algorithm <reference|algo-verify-slot-winner> is run as a part of the
  verification process, when a node is importing a block, in which:

  <\itemize-minus>
    <item><name|Epoch-Randomness> is defined in Algorithm
    <reference|algo-epoch-randomness>.

    <item><math|H<rsub|BABE><around*|(|B|)>> is the BABE header defined in
    Definition <reference|defn-babe-header>.

    <item><name|Verify-VRF> is described in Section <reference|sect-vrf>.

    <item><math|\<tau\>> is the winning threshold defined in
    <reference|defn-winning-threshold>.
  </itemize-minus>

  <\algorithm>
    <label|algo-verify-slot-winner><name|Verify-Slot-Winner>(<math|B>: the
    block whose winning status to be verified)
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|\<cal-E\><rsub|c>\<leftarrow\>><name|Current-Epoch>
      </state>

      <\state>
        <math|\<rho\>\<leftarrow\>><name|Epoch-Randomness><math|<around*|(|c|)>>
      </state>

      <\state>
        <name|Verify-VRF>(<math|\<rho\>,H<rsub|BABE><around*|(|B|)>.<around*|(|d<rsub|B>,\<pi\><rsub|B>|)>,H<rsub|BABE><around*|(|B|)>.s,c>)
      </state>

      <\state>
        <\IF>
          <math|d<rsub|B>\<geqslant\>\<tau\>>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PBlock producer is not a winner of the slot\Q<END>
        </ERROR>
      </state>
    </algorithmic>
  </algorithm>

  <math|<around*|(|d<rsub|B>,\<pi\><rsub|B>|)>><math|>: Block Lottery Result
  for Block <math|B>,\ 

  <math|s<rsub|n>>: the slot number,

  <math|n>: Epoch index

  AuthorID: The public session key of the block producer

  <subsection|Block Building Process><label|sect-block-building>

  The blocks building process is triggered by Algorithm
  <reference|algo-block-production> of the consensus engine which runs
  Alogrithm <reference|algo-build-block>.

  <\algorithm>
    <label|algo-build-block><name|Build-Block>(<math|C<rsub|Best>>: The chain
    where at its head, the block to be constructed,

    s: Slot number)
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|P<rsub|B>\<leftarrow\><rsub|>><name|Head(<math|C<rsub|Best>>)>
      </state>

      <\state>
        <math|Head<around*|(|B|)>\<leftarrow\>>(<math|H<rsub|p>\<leftarrow\>H<rsub|h><rsub|><around*|(|P<rsub|B>|)>,H<rsub|i>\<leftarrow\>H<rsub|i><around*|(|P<rsub|B>|)>+1,H<rsub|r>\<leftarrow\>\<phi\>,H<rsub|e>\<leftarrow\>\<phi\>,H<rsub|d>\<leftarrow\>\<phi\>>)
      </state>

      <\state>
        <name|Call-Runtime-Entry><math|<around*|(|<text|<verbatim|Core_initialize_block>>,Head<around*|(|<rsub|>B|)>|)>>
      </state>

      <\state>
        <name|Call-Runtime-Entry><math|<around*|(|<text|<verbatim|BlockBuilder_inherent_extrinsics>>,<text|<name|Inherent-Data>>|)>><END>
      </state>

      <\state>
        <\WHILE>
          <strong|not> <name|End-Of-Slot(s)>
        </WHILE>
      </state>

      <\state>
        <math|E\<leftarrow\>><name|Next-Ready-Extrinsic()>
      </state>

      <\state>
        <math|R\<leftarrow\>><name|Call-Runtime-Entry(><verbatim|BlockBuilder_apply_extrinsics>,<em|E>)
      </state>

      <\state>
        <\IF>
          <strong|not> <name|Block-Is-FULL(<math|R>>)
        </IF>
      </state>

      <\state>
        <name|Drop(Ready-Extrinsics-Queue>,<em|E>)<END>
      </state>

      <\state>
        <\ELSE>
          \;
        </ELSE>
      </state>

      <\state>
        <BREAK><END><END>
      </state>

      <\state>
        <math|Head<around*|(|B|)>\<leftarrow\>><name|Call-Runtime-Entry(><verbatim|BlockBuilder_finalize_block>,<em|B>)
      </state>
    </algorithmic>
  </algorithm>

  <\itemize-minus>
    <item><math|Head<around*|(|B|)>> is defined in Definition
    <reference|defn-block-header>.

    <item><name|Call-Runtime-Entry> is defined in Notation
    <reference|nota-call-into-runtime>.

    <item><name|Inherent-Data> is defined in Definition
    <reference|defn-inherent-data>.

    <item><name|Transaction-Queue> is defined in Definition
    <reference|defn-transaction-queue>.

    <item><name|Block-Is-Full> indicates that the maximum block size as been
    used.

    <item><name|End-Of-Slot> indicates the end of the BABE slot as defined in
    Algorithm <reference|algo-slot-time> respectively Definition
    <reference|defn-epoch-slot>.

    <item><name|Ok-Result> indicates whether the result of
    <verbatim|BlockBuilder_apply_extrinsics> is successfull. The error type
    of the Runtime function is defined in Definition <todo|define error
    type>.

    <item><name|Ready-Extrinsics-Queue> indicates picking an extrinsics from
    the extrinsics queue (Definition <reference|defn-transaction-queue>).

    <item><name|Drop> indicates removing the extrinsic from the transaction
    queue (Definition <reference|defn-transaction-queue>).
  </itemize-minus>

  <section|Finality><label|sect-finality>

  The Polkadot Host uses GRANDPA Finality protocol
  <cite|stewart_grandpa:_2019> to finalize blocks. Finality is obtained by
  consecutive rounds of voting by validator nodes. Validators execute GRANDPA
  finality process in parallel to Block Production as an independent service.
  In this section, we describe the different functions that GRANDPA service
  is supposed to perform to successfully participate in the block
  finalization process.

  <subsection|Preliminaries>

  <\definition>
    A <strong|GRANDPA Voter>, <math|v>, is represented by a key pair
    <math|<around|(|k<rsup|pr><rsub|v>,v<rsub|id>|)>> where
    <math|k<rsub|v><rsup|pr>> represents its private key which is an
    <math|ED25519> private key, is a node running GRANDPA protocol, and
    broadcasts votes to finalize blocks in a Polkadot Host - based chain. The
    <strong|set of all GRANDPA voters> is indicated by <math|\<bbb-V\>>. For
    a given block B, we have <todo|change function name, only call at
    genesis, adjust V_B over the sections>

    <\equation*>
      \<bbb-V\><rsub|B>=<text|<verbatim|grandpa_authorities>><around*|(|B|)>
    </equation*>

    where <math|<math-tt|grandpa_authorities>> is the entry into runtime
    described in Section <reference|sect-rte-grandpa-auth>.
  </definition>

  <\definition>
    <strong|GRANDPA state>, <math|GS>, is defined as <todo|verify V_id and
    id_V usage, unify>

    <\equation*>
      GS\<assign\><around|{|\<bbb-V\>,id<rsub|\<bbb-V\>>,r|}>
    </equation*>

    where:

    <math|<math-bf|\<bbb-V\>>>: is the set of voters.

    <math|<math-bf|id<rsub|\<bbb-V\>>>>: is an incremental counter tracking
    <verbatim|>membership, which changes in V.<todo|redefine as authority set
    id>

    <strong|r>: is the votin<verbatim|>g round number.
  </definition>

  Now we need to define how the Polkadot Host counts the number of votes for
  block <math|B>. First a vote is defined as:

  <\definition>
    <label|defn-vote>A <strong|GRANDPA vote >or simply a vote for block
    <math|B> is an ordered pair defined as

    <\equation*>
      V<rsub|\<nosymbol\>><around|(|B|)>\<assign\><around|(|H<rsub|h><around|(|B|)>,H<rsub|i><around|(|B|)>|)>
    </equation*>

    where <math|H<rsub|h><around|(|B|)>> and <math|H<rsub|i><around|(|B|)>>
    are the block hash and the block number defined in Definitions
    <reference|defn-block-header> and <reference|defn-block-header-hash>
    respectively.
  </definition>

  <\definition>
    Voters engage in a maximum of two sub-rounds of voting for each round
    <math|r>. The first sub-round is called <strong|pre-vote> and<verbatim|>
    the second sub-round is called <strong|pre-commit>.

    By <strong|<math|V<rsub|v><rsup|r,pv>>> and
    <strong|<math|V<rsub|v><rsup|r,pc>>> we refer to the vote cast by voter
    <math|v> in round <math|r> (for block <math|B>) during the pre-vote and
    the pre-commit sub-round respectively.
  </definition>

  The GRANDPA protocol dictates how an honest voter should vote in each
  sub-round, which is described in Algorithm <reference|algo-grandpa-round>.
  After defining what constitues a vote in GRANDPA, we define how GRANDPA
  counts votes.

  <\definition>
    Voter <math|v> <strong|equivocates> if they broadcast two or more valid
    votes to blocks not residing on the same branch of the block tree during
    one voting sub-round. In such a situation, we say that <math|v> is an
    <strong|equivocator> and any vote <math|V<rsub|v><rsup|r,stage><around*|(|B|)>>
    cast by <math|v> in that round is an <strong|equivocatory vote> and

    <\equation*>
      \<cal-E\><rsup|r,stage>
    </equation*>

    \ represents the set of all equivocators voters in sub-round
    \P<math|stage>\Q of round <math|r>. When we want to refer to the number
    of<verbatim|> equivocators whose equivocation has been observed by voter
    <math|v> we refer to it by:

    <\equation*>
      \<cal-E\><rsup|r,stage><rsub|obs<around*|(|v|)>>
    </equation*>

    \ 
  </definition>

  <\definition>
    A vote <math|V<rsub|v><rsup|r,stage>=V<around|(|B|)>> is <strong|invalid>
    if

    <\itemize>
      <\itemize-dot>
        <item><math|H<around|(|B|)>> does not correspond to a valid block;

        <item><math|B> is not an (eventual) descendant of a previously
        finalized block;

        <item><math|M<rsup|r,stage><rsub|v>> does not bear a valid signature;

        <item><math|id<rsub|\<bbb-V\>>> does not match the current
        <math|\<bbb-V\>>;

        <item>If <math|V<rsub|v><rsup|r,stage>> is an equivocatory vote.
      </itemize-dot>
    </itemize>
  </definition>

  <\definition>
    For validator v, <strong|the set of observed direct votes for Block
    <math|B> in round <math|r>>, formally denoted by
    <math|VD<rsup|r,stage><rsub|obs<around|(|v|)>><rsup|\<nosymbol\>><rsub|\<nosymbol\>><around|(|B|)>>
    is equal to the union of:

    <\itemize-dot>
      <item>set of valid votes <math|V<rsup|r,stage><rsub|v<rsub|i>>> cast in
      round <math|r> and received by v such that
      <math|V<rsup|r,stage><rsub|v<rsub|i>>=V<around|(|B|)>>.
    </itemize-dot>
  </definition>

  <\definition>
    We refer to <strong|the set of total votes observed by voter <math|v> in
    sub-round \P<math|stage>\Q of round <math|r>> by
    <strong|<math|V<rsup|r,stage><rsub|obs<around|(|v|)>><rsup|\<nosymbol\>><rsub|\<nosymbol\>>>>.

    The <strong|set of all observed votes by <math|v> in the sub-round stage
    of round <math|r> for block <math|B>>,
    <strong|<math|V<rsup|r,stage><rsub|obs<around|(|v|)>><around|(|B|)>>> is
    equal to all of the observed direct votes casted for block <math|B> and
    all of the <math|B>'s descendents defined formally as:

    <\equation*>
      V<rsup|r,stage><rsub|obs<around|(|v|)>><around|(|B|)>\<assign\><big|cup><rsub|v<rsub|i>\<in\>\<bbb-V\>,B\<geqslant\>B<rprime|'>>VD<rsup|r,stage><rsub|obs<around|(|v|)>><around|(|B<rprime|'>|)><rsub|\<nosymbol\>><rsup|\<nosymbol\>><rsub|\<nosymbol\>>
    </equation*>

    The <strong|total number of observed votes for Block <math|B> in round
    <math|r>> is defined to be the size of that set plus the total number of
    equivocators voters:

    <\equation*>
      #V<rsup|r,stage><rsub|obs<around|(|v|)>><around|(|B|)>=<around|\||V<rsup|r,stage><rsub|obs<around|(|v|)>><around|(|B|)>|\|>+<around*|\||\<cal-E\><rsup|r,stage><rsub|obs<around*|(|v|)>>|\|>
    </equation*>
  </definition>

  <\definition>
    The current <strong|pre-voted> block <math|B<rsup|r,pv><rsub|v>> is the
    block with

    <\equation*>
      H<rsub|n><around|(|B<rsup|r,pv><rsub|v>|)>=Max<around|(|<around|\<nobracket\>|H<rsub|n><around|(|B|)>|\|>*\<forall\>B:#V<rsub|obs<around|(|v|)>><rsup|r,pv><around|(|B|)>\<geqslant\>2/3<around|\||\<bbb-V\>|\|>|)>
    </equation*>
  </definition>

  Note that for genesis state <math|Genesis> we always have
  <math|#V<rsub|obs<around|(|v|)>><rsup|r,pv><around|(|B|)>=<around*|\||\<bbb-V\>|\|>>.

  \;

  Finally, we define when a voter <math|v> see a round as completable, that
  is when they are confident that <math|B<rsub|v><rsup|r,pv>> is an upper
  bound for what is going to be finalised in this round. \ 

  <\definition>
    <label|defn-grandpa-completable>We say that round <math|r> is
    <strong|completable> if <math|<around|\||V<rsup|r,pc><rsub|obs<around|(|v|)>>|\|>+\<cal-E\><rsup|r,pc><rsub|obs<around*|(|v|)>>\<gtr\><frac|2|3>\<bbb-V\>>
    and for all <math|B<rprime|'>\<gtr\>B<rsub|v><rsup|r,pv>>:

    <\equation*>
      <tabular|<tformat|<cwith|1|1|1|1|cell-valign|b>|<table|<row|<cell|<around|\||V<rsup|r,pc><rsub|obs<around|(|v|)>>|\|>-\<cal-E\><rsup|r,pc><rsub|obs<around*|(|v|)>>-<around|\||V<rsup|r,pc><rsub|obs<around|(|v|)><rsub|\<nosymbol\>>><around|(|B<rprime|'>|)>|\|>\<gtr\><frac|2|3><around|\||\<bbb-V\>|\|>>>>>>
    </equation*>
  </definition>

  Note that in practice we only need to check the inequality for those
  <math|B<rprime|'>\<gtr\>B<rsub|v><rsup|r,pv>> where
  <math|<around|\||V<rsup|r,pc><rsub|obs<around|(|v|)><rsub|\<nosymbol\>>><around|(|B<rprime|'>|)>|\|>\<gtr\>0>.\ 

  \;

  <subsection|GRANDPA Messages Specification>

  <subsubsection|Vote Messages>

  Voting is done by means of broadcasting voting messages to the network.
  Validators inform their peers about the block finalized in round <math|r>
  by broadcasting a finalization message (see Algorithm
  <reference|algo-grandpa-round> for more details). These messages are
  specified in this section.

  <\definition>
    A vote casted by voter <math|v> should be broadcasted as a
    <strong|message <math|M<rsup|r,stage><rsub|v>>> to the network by voter
    <math|v> with the following structure:

    <\equation*>
      M<rsup|r,stage><rsub|v>\<assign\>Enc<rsub|SC><around|(|stage,r,id<rsub|\<bbb-V\>>,Enc<rsub|SC><around|(|stage,V<rsub|v><rsup|r,stage>|\<nobracket\>>,Sig<rsub|ED25519><around|(|Enc<rsub|SC><around|(|stage,V<rsub|v><rsup|r,stage>|\<nobracket\>>,r,V<rsub|id>|)>,v<rsub|id>|)>
    </equation*>

    Where:

    <\center>
      <tabular*|<tformat|<cwith|1|-1|1|1|cell-halign|r>|<cwith|1|-1|1|1|cell-lborder|0ln>|<cwith|1|-1|2|2|cell-halign|l>|<cwith|1|-1|3|3|cell-halign|l>|<cwith|1|-1|3|3|cell-rborder|0ln>|<cwith|1|-1|1|-1|cell-valign|c>|<table|<row|<cell|r:>|<cell|round
      number>|<cell|64 bit integer>>|<row|<cell|<math|V<rsub|id>>:>|<cell|incremental
      change tracker counter>|<cell|64 bit
      integer>>|<row|<cell|<right-aligned|<math|v<rsub|id>>>:>|<cell|Ed25519
      public key of <math|v>>|<cell|32 byte
      array>>|<row|<cell|<right-aligned|><math|stage>:>|<cell|0 if it is the
      pre-vote sub-round>|<cell|1 byte>>|<row|<cell|>|<cell|1 if it the
      pre-commit sub-round>|<cell|>>>>>
    </center>

    \;
  </definition>

  <subsubsection|Finalizing Message>

  <\definition>
    <label|defn-grandpa-justification>The <strong|justification for block B
    in round <math|r>> of GRANDPA protocol defined
    <math|J<rsup|r,stage><around*|(|B|)>> is a vector of pairs of the type:

    <\equation*>
      <around*|(|V<around*|(|B<rprime|'>|)>,<around*|(|Sign<rsup|r,stage><rsub|v<rsub|i>><around*|(|B<rprime|'>|)>,v<rsub|id>|)>|)>
    </equation*>

    in which either

    <\equation*>
      B<rprime|'>\<geqslant\>B
    </equation*>

    or <math|V<rsup|r,pc><rsub|v<rsub|i>><around*|(|B<rprime|'>|)>> is an
    equivocatory vote.

    In all cases, <math|Sign<rsup|r,stage><rsub|v<rsub|i>><around*|(|B<rprime|'>|)>>
    is the signature of voter <math|v<rsub|i>> broadcasted during either the
    pre-vote (stage = pv) or the pre-commit (stage = pc) sub-round of round
    r. A valid Justification must not contain more than two equivocatory vote
    from each voter.\ 

    \;

    We say <math|J<rsup|r,pc><around*|(|B|)>> <strong|justifies the
    finalization> of <math|B> if the number of valid signatures in
    <math|J<rsup|r,pc><around*|(|B|)>> is greater than
    <math|<frac|2|3><around|\||\<bbb-V\><rsub|B>|\|>>.
  </definition>

  <\definition>
    <strong|<math|GRANDPA> finalizing message for block <math|B> in round
    <math|r>> represented as <strong|<math|M<rsub|v><rsup|r,Fin>>(B)> is a
    message broadcasted by voter <math|v> to the network indicating that
    voter <math|v> has finalized block <math|B> in round <math|r>. It has the
    following structure:

    <\equation*>
      M<rsup|r,Fin><rsub|v><around*|(|B|)>\<assign\>Enc<rsub|SC><around|(|r,V<around*|(|B|)>,J<rsup|r,pc><around*|(|B|)>|)>
    </equation*>

    in which <math|J<rsup|r><around*|(|B|)>> in the justification defined in
    Definition <reference|defn-grandpa-justification>.
  </definition>

  <subsubsection|Catch-up Messages><label|sect-grandpa-catchup-messages>

  Whenever a Polkadot node detects likely by means of neighbor packet network
  message (see Section <reference|sect-msg-neighbor-packet>) that it is
  lagging behind the finality procedure and therefore needs to initiate a
  catch-up procedure explained in Section <reference|sect-grandpa-catchup> by
  means of sending <em|catch-up request> and processing <em|catch-up
  response> as specified here:

  <\definition>
    <label|defn-grandpa-catchup-request-msg><strong|GRANDPA catch-up request
    message for round r> represented as <strong|<math|M<rsub|i,v><rsup|Cat-q><around*|(|id<rsub|\<bbb-V\>>,r|)>>>
    is a message sent from node <math|i> to its voting peer node <math|v>
    requesting the latest status of a GRANDPA round
    <math|r<rprime|'>\<gtr\>r> of of authority set <math|\<bbb-V\><rsub|id>>
    along with the justification of the status and has the followin
    structure:

    <\equation*>
      M<rsub|i,v><rsup|Cat-q><around*|(|id<rsub|\<bbb-V\>>,r|)>\<assign\>Enc<rsub|SC><around*|(|r,id<rsub|\<bbb-V\>>|)>
    </equation*>
  </definition>

  <\definition>
    <label|defn-grandpa-catchup-response-msg><strong|GRANDPA catch-up
    response message for round r> formally denoted as
    \ <strong|<math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>>>
    is a message sent by a node <math|v> to node i in response of a catch up
    request <math|M<rsub|v,i><rsup|Cat-q><around*|(|id<rsub|\<bbb-V\>>,r<rprime|'>|)>>
    in which <math|r\<geqslant\>r<rprime|'>> is the latest GRNADPA round
    which v has prove of its finalization and has the following structure:

    <\equation*>
      M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>\<assign\>Enc<rsub|SC><around*|(|id<rsub|\<bbb-V\>>,r,J<rsup|r,pv><around*|(|B|)>,J<rsup|r,pc><around*|(|B|)>,H<rsub|h><around*|(|B<rprime|'>|)>,H<rsub|i><around*|(|B<rprime|'>|)>|)>
    </equation*>
  </definition>

  <subsection|Initiating the GRANDPA State>

  A validator needs to initiate its state and sync it with other validators,
  to be able to participate coherently in the voting process. In particular,
  considering that voting is happening in different rounds and each round of
  voting is assigned a unique sequential round number <math|r<rsub|v>>, it
  needs to determine and set its round counter <math|r> in accordance with
  the current voting round <math|r<rsub|n>>, which is currently undergoing in
  the network. Algorithm <reference|algo-initiate-grandpa>\ 

  <\algorithm>
    <label|algo-initiate-grandpa><name|Initiate-Grandpa>(<math|r<rsub|last>>:
    last round number or 0 if the voter starting a new authority set,

    , <math|B<rsub|last>>: the last block which has been finalized on the
    chain)
  <|algorithm>
    <\algorithmic>
      <\state>
        <name|Last-Finalized-Block><math|\<leftarrow\>><math|B<rsub|last>>
      </state>

      <\state>
        <\IF>
          <math|r<rsub|last>=0>
        </IF>
      </state>

      <\state>
        <name|Last-Round-Estimate><math|=B<rsub|last>><END>

        <name|Last-Round-Prevote-GHOST><math|=B<rsub|last>><END>
      </state>

      <\state>
        <math|r<rsub|n>\<leftarrow\>r<rsub|last+1>>
      </state>

      <\state>
        <name|Play-Grandpa-round>(<math|r<rsub|n>>)
      </state>
    </algorithmic>
  </algorithm>

  <subsubsection|Voter Set Changes>

  Voter set changes are signaled by Runtime via a consensus engine message as
  described in Section <reference|sect-consensus-message-digest>. When
  Authorities process such messages they must not vote on any block with
  higher number than the block at which the change is supposed to happen. The
  new authority set should reinitiate GRANDPA protocol by exectutig Algorithm
  <reference|algo-initiate-grandpa>.

  <subsection|Voting Process in Round <math|r>>

  For each round <math|r>, an honest voter <math|v> must participate in the
  voting process by following Algorithm <reference|algo-grandpa-round>.

  <\algorithm|<label|algo-grandpa-round><name|Play-Grandpa-round><math|<around|(|r|)>>>
    <\algorithmic>
      <\state>
        <math|t<rsub|r,v>\<leftarrow\>>Time
      </state>

      <\state>
        <math|primary\<leftarrow\>><name|Derive-Primary>
      </state>

      <\state>
        <\IF>
          <math|v=primary>
        </IF>
      </state>

      <\state>
        <name|Broadcast(><left|.><math|M<rsub|v<rsub|\<nosymbol\>>><rsup|r-1,Fin>>(<name|Best-Final-Candidate>(<math|r>-1))<right|)><END>
      </state>

      <\state>
        <name|Receive-Messages>(<strong|until> Time
        <math|\<geqslant\>t<rsub|r<rsub|,>*v>+2\<times\>T> <strong|or>
        <math|r> <strong|is> completable)<END>
      </state>

      <\state>
        <math|L\<leftarrow\>><name|Best-Final-Candidate>(<math|r>-1)
      </state>

      <\state>
        <\IF>
          <name|Received(<math|M<rsub|v<rsub|primary>><rsup|r,pv><around|(|B|)>>)>
          <strong|and> <math|B<rsup|r,pv><rsub|v>\<geqslant\>B\<gtr\>L>
        </IF>
      </state>

      <\state>
        <math|N\<leftarrow\>B><END>
      </state>

      <\state>
        <\ELSE>
          \;
        </ELSE>
      </state>

      <\state>
        <math|N\<leftarrow\>B<rprime|'>:H<rsub|n><around|(|B<rprime|'>|)>=max
        <around|{|H<rsub|n><around|(|B<rprime|'>|)>:B<rprime|'>\<gtr\>L|}><END>>
      </state>

      <\state>
        <name|Broadcast>(<math|M<rsub|v><rsup|r,pv><around|(|N|)>>)
      </state>

      <\state>
        <name|Receive-Messages>(<strong|until>
        <math|B<rsup|r,pv<rsub|\<nosymbol\>>><rsub|v>\<geqslant\>L>
        <strong|and> (Time <math|\<geqslant\>t<rsub|r<rsub|,>*v>+4\<times\>T><strong|
        or ><math|r> <strong|is> completable))
      </state>

      <\state>
        <name|Broadcast(<math|M<rsub|v><rsup|r,pc>>(<math|B<rsub|v><rsup|r,pv>>))>
      </state>

      <\state>
        <name|Attempt-To-Finalize-Round>(<math|r>)
      </state>

      <\state>
        <name|Receive-Messages>(<strong|until> <math|r> <strong|is>
        completable)
      </state>

      <\state>
        <name|Play-Grandpa-round>(<math|r+1>)
      </state>
    </algorithmic>
  </algorithm>

  The condition of <em|completablitiy> is defined in Definition
  <reference|defn-grandpa-completable>. <name|Best-Final-Candidate> function
  is explained in Algorithm <reference|algo-grandpa-best-candidate> and
  <name|<name|Attempt-To-Finalize-Round>(<math|r>)> is described in Algorithm
  <reference|algo-attempt-to\Ufinalize>.

  <\algorithm|<label|algo-grandpa-best-candidate><name|Best-Final-Candidate>(<math|r>)>
    <\algorithmic>
      <\state>
        <math|\<cal-C\><rsub|\<nosymbol\>>\<leftarrow\><around|{|B<rprime|'>\|B<rprime|'>\<leqslant\>B<rsub|v><rsup|r,pv>:<around|\||V<rsub|v><rsup|r,pc>|\|>-#V<rsub|v><rsup|r,pc><around|(|B<rprime|'>|)>\<leqslant\>1/3<around|\||\<bbb-V\>|\|>|}>>
      </state>

      <\state>
        <\IF>
          <math|\<cal-C\>=\<phi\>>
        </IF>
      </state>

      <\state>
        <\RETURN>
          <math|\<phi\>><END>
        </RETURN>
      </state>

      <\state>
        <\ELSE>
          \;
        </ELSE>
      </state>

      <\state>
        <\RETURN>
          <math|E\<in\>\<cal-C\>:H<rsub|n><around*|(|E|)>=max
          <around|{|H<rsub|n><around|(|B<rprime|'>|)>:B<rprime|'>\<in\>\<cal-C\>|}>><END>
        </RETURN>
      </state>
    </algorithmic>
  </algorithm>

  <\algorithm|<label|algo-attempt-to\Ufinalize><name|Attempt-To-Finalize-Round>(<math|r>)>
    <\algorithmic>
      <\state>
        <math|L\<leftarrow\>><name|Last-Finalized-Block>
      </state>

      <\state>
        <math|E\<leftarrow\>><name|Best-Final-Candidate>(<math|r>)
      </state>

      <\state>
        <\IF>
          <math|E\<geqslant\>L> <strong|and>
          <math|V<rsup|r,pc><rsub|obs<around|(|v|)>><rsup|\<nosymbol\>><rsub|\<nosymbol\>><around|(|E|)>\<gtr\>2/3<around|\||\<bbb-V\>|\|>>
        </IF>
      </state>

      <\state>
        <name|Last-Finalized-Block><math|\<leftarrow\>E>
      </state>

      <\state>
        <\IF>
          <math|M<rsub|v><rsup|r,Fin><around|(|E|)>\<nin\>><name|Received-Messages>
        </IF>
      </state>

      <\state>
        <name|Broadcast>(<math|M<rsub|v><rsup|r,Fin><around|(|E|)>>)
      </state>

      <\state>
        <\RETURN>
          <END><END>
        </RETURN>
      </state>

      <\state>
        <strong|schedule-call> <name|Attempt-To-Finalize-Round>(<math|r>)
        <strong|when> <name|Receive-Messages>\ 
      </state>
    </algorithmic>
  </algorithm>

  <section|Block Finalization><label|sect-block-finalization>

  <\definition>
    <label|defn-finalized-block>A Polkadot relay chain node n should consider
    block <math|B> as <strong|finalized> if any of the following criteria
    holds for <math|B<rprime|'>\<geqslant\>B>:\ 

    <\itemize>
      <item><math|V<rsup|r,pc><rsub|obs<around|(|n|)>><rsup|\<nosymbol\>><rsub|\<nosymbol\>><around|(|B<rprime|'>|)>\<gtr\>2/3<around|\||\<bbb-V\><rsub|B<rprime|'>>|\|>>.

      <item>it receives a <math|M<rsub|v><rsup|r,Fin><around|(|B<rprime|'>|)>>
      message in which <math|J<rsup|r><around*|(|B|)>> justifies the
      finalization (according to Definition
      <reference|defn-grandpa-justification>).

      <item>it receives a block data message for <math|B<rprime|'>> with
      <math|Just<around*|(|B<rprime|'>|)>> defined in Section
      <reference|sect-justified-block-header> which justifies the
      finalization.\ 
    </itemize>
  </definition>

  for\ 

  <\itemize-dot>
    <item>any round <math|r> if the node <math|n> is <em|not> a GRANDPA
    voter.\ 

    <item>only for rounds <math|r> for which the the node <math|n> has
    invoked Algorithm <reference|algo-grandpa-round> if <math|n> is a GRANDPA
    voter.
  </itemize-dot>

  Note that all Polkadot relay chain nodes are supposed to listen to GRANDPA
  finalizing messages regardless if they are GRANDPA voters.

  <subsection|Catching up><label|sect-grandpa-catchup>

  When a Polkadot node (re)joins the network during the process described in
  Chapter <reference|chap-bootstrapping>, it requests the history of state
  transition which it is missing in form of blocks. Each finalized block
  comes with the Justification of its finalization as defined in Definition
  <reference|defn-grandpa-justification> <todo|Verify: you can't trust your
  neigbour for their set, you need to get it from the chain>. Through this
  process they can synchronize the authority list which is currently
  performing the finalization process.

  <subsubsection|Sending catch-up request><label|sect-sending-catchup-request>

  When a Polkadot node has the same authority list as a peer node who is
  reporting a higher number for the \Pfinalized round\Q field, they should
  send a catch-up request message as specified in Definition
  <reference|defn-grandpa-catchup-request-msg> to the reporting peer in order
  to catch-up to the more advanced finalized round, provided that the
  following criteria holds:

  <\itemize-minus>
    <item>the peer node is a GRANDPA voter.

    <item>The last known finalized round for the Polkadot node is at least 2
    rounds behind the finalized round by the peer.\ 
  </itemize-minus>

  \ <subsubsection|Processing catch-up request>

  Only GRANDPA voter nodes are required to respond to the catch up responses.
  When a GRANDPA voter node receive a catch-up request message it needs to
  executes Algorithm <reference|algo-process-catchup-request>.

  <\algorithm>
    <label|algo-process-catchup-request><name|ProcessCatchupRequest>(

    <math|M<rsub|i,v><rsup|Cat-q><around*|(|id<rsub|\<bbb-V\>>,r|)>>: The
    catch-up message received from peer <math|i> (See Definition
    <reference|defn-grandpa-catchup-request-msg>)

    )
  <|algorithm>
    <\algorithmic>
      <\state>
        <\IF>
          <math|M<rsub|i,v><rsup|Cat-q><around*|(|id<rsub|\<bbb-V\>>,r|)>.id<rsub|\<bbb-V\>>\<neq\>id<rsub|\<bbb-V\>>>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PCatching up on different set\Q<END>
        </ERROR>
      </state>

      <\state>
        <\IF>
          <math|i\<nin\>\<bbb-P\>>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PRequesting catching up from a non-peer\Q<END>
        </ERROR>
      </state>

      <\state>
        <\IF>
          <math|r\<gtr\>><name|Last-Completed-Round>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PCatching up on a round in the future\Q<END>
        </ERROR>
      </state>

      <\state>
        <name|Send(<math|i>,><math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>>)
      </state>
    </algorithmic>
  </algorithm>

  In which:

  <\itemize-minus>
    <item><math|id<rsub|\<bbb-V\>>> is the voter set id which the serving
    node is operation

    <item><math|r> is the round number for which the catch-up is requested
    for.

    <item><math|\<bbb-P\>> is the set of immediate peers of node <math|v>.

    <item><name|Last-Completed-Round> is <todo|define:
    https://github.com/w3f/polkadot-spec/issues/161>

    <item><math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>> is
    the catch-up response defined in Definition
    <reference|defn-grandpa-catchup-response-msg>.
  </itemize-minus>

  <subsubsection|Processing catch-up response>

  A Catch-up response message contains critical information for the requester
  node to update their view on the active rounds which are being voted on by
  GRANDPA voters. As such, the requester node should verify the content of
  the catch-up response message and subsequently updates its view of the
  state of finality of the Relay chain according to Algorithm
  <reference|algo-process-catchup-response>.

  <\algorithm>
    <label|algo-process-catchup-response> <name|Process-Catchup-Response>(

    <math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>>: the
    catch-up response received from node <math|v> (See Definition
    <reference|defn-grandpa-catchup-response-msg>)

    )
  <|algorithm>
    <\algorithmic>
      <\state>
        <math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>.id<rsub|\<bbb-V\>>,r,J<rsup|r,pv><around*|(|B|)>,J<rsup|r,pc><around*|(|B|)>,H<rsub|h><around*|(|B<rprime|'>|)>,H<rsub|i><around*|(|B<rprime|'>|)>\<leftarrow\>><math|Dec<rsub|SC>>(<math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>>)
      </state>

      <\state>
        <\IF>
          <math|M<rsub|v,i><rsup|Cat-s><around*|(|id<rsub|\<bbb-V\>>,r|)>.id<rsub|\<bbb-V\>>\<neq\>id<rsub|\<bbb-V\>>>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PCatching up on different set\Q<END>
        </ERROR>
      </state>

      <\state>
        <\IF>
          <math|r\<leqslant\>><name|Leading-Round>
        </IF>
      </state>

      <\state>
        <\ERROR>
          \PCatching up in to the past\Q<END>
        </ERROR>
      </state>

      <\state>
        TBS
      </state>

      <\state>
        <name|Last-Completed-Round><math|\<leftarrow\>r>
      </state>

      <\state>
        <\IF>
          <math|i\<in\>\<bbb-V\>>
        </IF>
      </state>

      <\state>
        <name|Play-Grandpa-round><math|<around|(|r|)>><END>
      </state>
    </algorithmic>
  </algorithm>

  <\with|par-mode|right>
    <qed>
  </with>

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|papyrus>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|algo-attempt-to\Ufinalize|<tuple|6.11|?>>
    <associate|algo-block-production|<tuple|6.3|?>>
    <associate|algo-block-production-lottery|<tuple|6.1|?>>
    <associate|algo-build-block|<tuple|6.7|?>>
    <associate|algo-epoch-randomness|<tuple|6.4|?>>
    <associate|algo-grandpa-best-candidate|<tuple|6.10|?>>
    <associate|algo-grandpa-round|<tuple|6.9|?>>
    <associate|algo-initiate-grandpa|<tuple|6.8|?>>
    <associate|algo-process-catchup-request|<tuple|6.12|?>>
    <associate|algo-slot-time|<tuple|6.2|?>>
    <associate|algo-verify-authorship-right|<tuple|6.5|?>>
    <associate|algo-verify-slot-winner|<tuple|6.6|?>>
    <associate|auto-1|<tuple|6|?>>
    <associate|auto-10|<tuple|6.2.4|?>>
    <associate|auto-11|<tuple|6.2.5|?>>
    <associate|auto-12|<tuple|6.2.6|?>>
    <associate|auto-13|<tuple|6.2.7|?>>
    <associate|auto-14|<tuple|6.3|?>>
    <associate|auto-15|<tuple|6.3.1|?>>
    <associate|auto-16|<tuple|6.3.2|?>>
    <associate|auto-17|<tuple|6.3.2.1|?>>
    <associate|auto-18|<tuple|6.3.2.2|?>>
    <associate|auto-19|<tuple|6.3.2.3|?>>
    <associate|auto-2|<tuple|6.1|?>>
    <associate|auto-20|<tuple|6.3.3|?>>
    <associate|auto-21|<tuple|6.3.3.1|?>>
    <associate|auto-22|<tuple|6.3.4|?>>
    <associate|auto-23|<tuple|6.4|?>>
    <associate|auto-24|<tuple|6.4.1|?>>
    <associate|auto-25|<tuple|6.4.1.1|?>>
    <associate|auto-26|<tuple|6.4.1.2|?>>
    <associate|auto-3|<tuple|6.1.1|?>>
    <associate|auto-4|<tuple|6.1.2|?>>
    <associate|auto-5|<tuple|6.1|?>>
    <associate|auto-6|<tuple|6.2|?>>
    <associate|auto-7|<tuple|6.2.1|?>>
    <associate|auto-8|<tuple|6.2.2|?>>
    <associate|auto-9|<tuple|6.2.3|?>>
    <associate|chap-consensu|<tuple|6|?>>
    <associate|defn-authority-list|<tuple|6.1|?>>
    <associate|defn-babe-header|<tuple|6.12|?>>
    <associate|defn-babe-seal|<tuple|6.13|?>>
    <associate|defn-block-signature|<tuple|6.13|?>>
    <associate|defn-block-time|<tuple|6.10|?>>
    <associate|defn-consensus-message-digest|<tuple|6.2|?>>
    <associate|defn-epoch-slot|<tuple|6.5|?>>
    <associate|defn-epoch-subchain|<tuple|6.7|?>>
    <associate|defn-finalized-block|<tuple|6.29|?>>
    <associate|defn-grandpa-catchup-request-msg|<tuple|6.27|?>>
    <associate|defn-grandpa-catchup-response-msg|<tuple|6.28|?>>
    <associate|defn-grandpa-completable|<tuple|6.23|?>>
    <associate|defn-grandpa-justification|<tuple|6.25|?>>
    <associate|defn-slot-offset|<tuple|6.11|?>>
    <associate|defn-vote|<tuple|6.16|?>>
    <associate|defn-winning-threshold|<tuple|6.8|?>>
    <associate|note-slot|<tuple|6.6|?>>
    <associate|sect-authority-set|<tuple|6.1.1|?>>
    <associate|sect-babe|<tuple|6.2|?>>
    <associate|sect-block-building|<tuple|6.2.7|?>>
    <associate|sect-block-finalization|<tuple|6.4|?>>
    <associate|sect-block-production|<tuple|6.2|?>>
    <associate|sect-consensus-message-digest|<tuple|6.1.2|?>>
    <associate|sect-epoch-randomness|<tuple|6.2.5|?>>
    <associate|sect-finality|<tuple|6.3|?>>
    <associate|sect-grandpa-catchup|<tuple|6.4.1|?>>
    <associate|sect-grandpa-catchup-messages|<tuple|6.3.2.3|?>>
    <associate|sect-sending-catchup-request|<tuple|6.4.1.1|?>>
    <associate|sect-verifying-authorship|<tuple|6.2.6|?>>
    <associate|slot-time-cal-tail|<tuple|6.9|?>>
    <associate|tabl-consensus-messages|<tuple|6.1|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|bib>
      w3f_research_group_blind_2019

      david_ouroboros_2018

      stewart_grandpa:_2019
    </associate>
    <\associate|table>
      <tuple|normal|<\surround|<hidden-binding|<tuple>|6.1>|>
        The consensus digest item for GRANDPA authorities
      </surround>|<pageref|auto-5>>
    </associate>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|6<space|2spc>Consensus>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      6.1<space|2spc>Common Consensus Structures
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>

      <with|par-left|<quote|1tab>|6.1.1<space|2spc>Consensus Authority Set
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|6.1.2<space|2spc>Runtime-to-Consensus
      Engine Message <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      6.2<space|2spc>Block Production <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>

      <with|par-left|<quote|1tab>|6.2.1<space|2spc>Preliminaries
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <with|par-left|<quote|1tab>|6.2.2<space|2spc>Block Production Lottery
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>

      <with|par-left|<quote|1tab>|6.2.3<space|2spc>Slot Number Calculation
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|1tab>|6.2.4<space|2spc>Block Production
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <with|par-left|<quote|1tab>|6.2.5<space|2spc>Epoch Randomness
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11>>

      <with|par-left|<quote|1tab>|6.2.6<space|2spc>Verifying Authorship Right
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12>>

      <with|par-left|<quote|1tab>|6.2.7<space|2spc>Block Building Process
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13>>

      6.3<space|2spc>Finality <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-14>

      <with|par-left|<quote|1tab>|6.3.1<space|2spc>Preliminaries
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-15>>

      <with|par-left|<quote|1tab>|6.3.2<space|2spc>GRANDPA Messages
      Specification <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-16>>

      <with|par-left|<quote|2tab>|6.3.2.1<space|2spc>Vote Messages
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-17>>

      <with|par-left|<quote|2tab>|6.3.2.2<space|2spc>Finalizing Message
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-18>>

      <with|par-left|<quote|2tab>|6.3.2.3<space|2spc>Catch-up Messages
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-19>>

      <with|par-left|<quote|1tab>|6.3.3<space|2spc>Initiating the GRANDPA
      State <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-20>>

      <with|par-left|<quote|2tab>|6.3.3.1<space|2spc>Voter Set Changes
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-21>>

      <with|par-left|<quote|1tab>|6.3.4<space|2spc>Voting Process in Round
      <with|mode|<quote|math>|r> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-22>>

      6.4<space|2spc>Block Finalization <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-23>

      <with|par-left|<quote|1tab>|6.4.1<space|2spc>Catching up
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-24>>

      <with|par-left|<quote|2tab>|6.4.1.1<space|2spc>Sending catch-up request
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-25>>

      <with|par-left|<quote|2tab>|6.4.1.2<space|2spc>Processing catch-up
      request <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-26>>
    </associate>
  </collection>
</auxiliary>