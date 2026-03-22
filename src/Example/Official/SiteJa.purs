module Example.Official.SiteJa
  ( officialSiteJa
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Portico
  ( Block(..)
  , CalloutTone(..)
  , PageKind(..)
  , Site
  , callout
  , collectionLinkCard
  , collectionNavItem
  , codeSample
  , faqEntry
  , feature
  , hero
  , japaneseLocale
  , japaneseSiteLabels
  , linkCard
  , metric
  , namedSection
  , navItem
  , page
  , site
  , slugLinkCard
  , slugNavItem
  , timelineEntry
  , withActions
  , withDescription
  , withEyebrow
  , withLocale
  , withNavigation
  , withSiteLabels
  , withSummary
  )

officialSiteJa :: Site
officialSiteJa =
  withLocale japaneseLocale
    (withSiteLabels japaneseSiteLabels
      (withNavigation
        [ slugNavItem "始める" startSlug
        , slugNavItem "テーマ" themeSlug
        , slugNavItem "公開" publishabilitySlug
        , slugNavItem "リファレンス" referenceSlug
        , collectionNavItem "ラボ" labHomePath
        , navItem "GitHub" githubRepositoryHref
        ]
        (withDescription
          "PureScript で公開サイトを組み立てるための、静的サイト向けライブラリ。"
          (site
            "Portico"
            [ homePage
            , whyPage
            , startPage
            , aiPage
            , referencePage
            , themePage
            , publishabilityPage
            , releasePage
            ]))))
  where
  whySlug = "learn/fit"

  startSlug = "guide/getting-started"

  aiPathSlug = "guide/ai-path"

  referenceSlug = "reference/public-surface"

  themeSlug = "guide/theme-system"

  publishabilitySlug = "guide/publishability"

  releaseSlug = "releases/0-1-0"

  labHomePath = "lab/index.html"

  presetCatalogPath = "lab/presets.html"

  docsSamplePath = "samples/northline-docs/index.html"

  productSamplePath = "samples/northstar-cloud/index.html"

  profileSamplePath = "samples/mina-arai/index.html"

  summitSamplePath = "samples/signal-summit/index.html"

  githubRepositoryHref = "https://github.com/M-simplifier/portico"

  githubAgentQuickstartHref = githubRepositoryHref <> "/blob/main/docs/agent-quickstart.md"

  githubSkillHref = githubRepositoryHref <> "/blob/main/skills/portico-user/SKILL.md"

  githubVisionHref = githubRepositoryHref <> "/blob/main/docs/vision.md"

  githubArchitectureHref = githubRepositoryHref <> "/blob/main/docs/architecture.md"

  githubDeploymentHref = githubRepositoryHref <> "/blob/main/docs/deployment.md"

  githubDistributionHref = githubRepositoryHref <> "/blob/main/docs/distribution.md"

  githubReleaseChecklistHref = githubRepositoryHref <> "/blob/main/docs/release-checklist.md"

  gettingStartedCode =
    "import Portico\n\nsiteDefinition =\n  site \"Signal Manual\"\n    [ withSummary\n        \"A calm docs front door.\"\n        (page \"index\" Landing \"Signal Manual\"\n          [ namedSection \"Overview\"\n              [ HeroBlock\n                  (withEyebrow\n                    \"Published public surfaces\"\n                    (hero\n                      \"Build a real front door.\"\n                      \"Model the site semantically and keep the path static-first.\"))\n              ]\n          ])\n    ]\n\nmain = do\n  let report = validateSite siteDefinition\n  emitSite \"site/dist\" officialTheme siteDefinition"

  themeCode =
    "import Portico\n\nsiteTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#2563eb\"\n      , spacing = Just\n          { pageInset: \"3.6rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"6rem\"\n          , sectionGap: \"4.2rem\"\n          , stackGap: \"1.35rem\"\n          , cardPadding: \"1.45rem\"\n          , heroPadding: \"2.7rem\"\n          }\n      })"

  localizedCode =
    "import Portico\n\nlocalizedDefinition =\n  localizedSite\n    englishLocale\n    [ localizedVariant englishLocale \"English\" \"\" englishSite\n    , localizedVariant japaneseLocale \"Japanese\" \"ja\" japaneseSite\n    ]\n\nmain = do\n  let report = validateLocalizedSite localizedDefinition\n  emitLocalizedSite \"site/dist\" officialTheme localizedDefinition"

  aiChecklistCode =
    "Use Portico for published static sites.\nImport from Portico.\nPrefer site, page, section, and semantic blocks.\nUse route helpers instead of hand-written relative links.\nKeep theme concerns separate from content structure.\nRun validateSite or validateLocalizedSite before publish.\nEmit output with emitSite, emitMountedSite, or emitLocalizedSite."

  homePage =
    withSummary
      "意味のある構造、公式テーマ、検証、静的出力をひとつに保つ Portico の公式サイト。"
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "概要"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "ここから始める" startSlug (Just "ひとつの import から、動くサイトと公開可能なビルドまで進みます。")
                  , collectionLinkCard "サンプルラボを見る" labHomePath (Just "ドキュメント、ランディング、ポートフォリオ、イベント、出版系の作例を見比べます。")
                  , linkCard "GitHub を開く" githubRepositoryHref (Just "リポジトリ、文書、現在のプレベータ公開面を確認します。")
                  ]
                  (withEyebrow
                    "公開サイト"
                    (hero
                      "公開サイトの front door を、静的に組み立てる。"
                      "Portico は、ドキュメント、公式サイト、リリースページ、ポートフォリオ、読み物のための PureScript ライブラリです。サイト構造を意味で書き、公式テーマから始め、公開前に検証し、静的出力まで一続きで扱えます。")))
            , MetricsBlock
                [ metric "公開面の入口" "`Portico`" (Just "site、theme、render、validate、build をひとつの import にまとめます。")
                , metric "圧力テスト用サンプル" "6" (Just "docs、product、portfolio、profile、event、publication を用意しています。")
                , metric "公式サイトの言語" "2 locales" (Just "英語を root、日本語を /ja/ に出力します。")
                , metric "リリースゲート" "`npm run verify`" (Just "テスト、公式サイト、Pages 向け出力までまとめて確認します。")
                ]
            , CodeBlock
                (codeSample
                  gettingStartedCode
                  (Just "purescript")
                  (Just "サイトモデルから静的出力へ"))
            ]
        , namedSection
            "Portico が何を狙うか"
            [ ProseBlock "多くのサイトツールは、テンプレート、Markdown パイプライン、あるいは生のレイアウト自由度から始まります。Portico はその一段上、公開サイトの情報設計から始めます。"
            , FeatureGridBlock
                [ feature "意味のあるサイトモデル" "site、page、section、navigation、block を値として保ち、場当たり的なマークアップに埋めません。"
                , feature "公式テーマシステム" "まず視覚の方向を選び、そのあとで palette、typography、spacing、surface を段階的に調整します。"
                , feature "公開前チェック" "壊れた route、弱い summary、重複 section、メタデータ不足を公開前に見つけます。"
                , feature "静的ファーストな多言語化" "locale ごとに実ページを出力し、lang や alternate metadata もビルド側で扱います。"
                ]
            , CalloutBlock
                (callout Strong "Asterism の軽量版ではない" "認証、長く生きる状態、重い相互作用、アプリシェル寄りの振る舞いが必要なら、中心はすでに Portico の外です。")
            ]
        , namedSection
            "向いているサイト"
            [ FeatureGridBlock
                [ feature "公式プロジェクトサイト" "何のプロダクトか、どう始めるか、どこに深い説明があるかを安定して見せる front door。"
                , feature "ドキュメントとガイド" "概念、導入、ネストした reference、リリース隣接の情報を落ち着いて読ませる面。"
                , feature "リリースと changelog" "静的公開に強い、更新記録と発表のためのページ。"
                , feature "ポートフォリオと読み物" "構造とリズムが大事で、相互作用の密度は主役でない公開面。"
                ]
            , LinkGridBlock
                [ slugLinkCard "Portico が向く場所" whySlug (Just "カテゴリ境界と設計中心をまとめて確認します。")
                , slugLinkCard "AI ワークフロー" aiPathSlug (Just "実装エージェントを同じ細い道筋に乗せます。")
                , slugLinkCard "リファレンス" referenceSlug (Just "現在の公開モジュール群と運用ルールを確認します。")
                , slugLinkCard "ここから始める" startSlug (Just "最小の導入経路へ進みます。")
                ]
            ]
        , namedSection
            "作って確かめる"
            [ CalloutBlock
                (callout Accent "公式サイトも dog fooding する" "英語版、日本語版、そして mounted sample lab まで、Portico 自身で出力しています。証拠面をライブラリの外に逃がさないためです。")
            , LinkGridBlock
                [ collectionLinkCard "サンプルラボを見る" labHomePath (Just "複数カテゴリの公開サイトを横断して比較します。")
                , collectionLinkCard "プリセットカタログを見る" presetCatalogPath (Just "細かな調整の前に、サイトの意図からテーマを選びます。")
                , slugLinkCard "テーマシステム" themeSlug (Just "プリセットと layered customization の関係を確認します。")
                , slugLinkCard "公開" publishabilitySlug (Just "検証、メタデータ、多言語出力、公開向けファイルを確認します。")
                ]
            ]
        , namedSection
            "現在地"
            [ CalloutBlock
                (callout Quiet "Public pre-beta" "Portico はもう評価できる状態ですが、公開契約はまだ固まり切っていません。いまの真実はリポジトリ、公式サイト、npm run verify にあります。")
            , LinkGridBlock
                [ slugLinkCard "Release 0.1.0" releaseSlug (Just "いま出ているものと、まだ動いているものを整理して見ます。")
                , linkCard "GitHub を開く" githubRepositoryHref (Just "コード、文書、issue、現在の公開姿勢を確認します。")
                , linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages 向けの base URL と公開フローです。")
                , linkCard "CONTRIBUTING" (githubRepositoryHref <> "/blob/main/CONTRIBUTING.md") (Just "プレベータ時点の contribution posture を確認します。")
                ]
            ]
        ])

  whyPage =
    withSummary
      "Portico が向く場所と、なぜスコープを狭く保っているか。"
      (page
        whySlug
        (CustomKind "Why")
        "Portico が向く場所"
        [ namedSection
            "設計中心"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "ここから始める" startSlug (Just "最小の authoring path から入ります。")
                  , slugLinkCard "公開" publishabilitySlug (Just "release 向けの validation と metadata の側面を確認します。")
                  , collectionLinkCard "サンプルラボを見る" labHomePath (Just "複数カテゴリで Portico を圧力テストします。")
                  ]
                  (withEyebrow
                    "Scope"
                    (hero
                      "静的サイトのライブラリは、公開構造を理解しているべきです。"
                      "Portico は、promise、path、proof、そして落ち着いた読書リズムが必要な公開面のためにあります。app shell をつくるためではありません。")))
            , FeatureGridBlock
                [ feature "公式サイト" "プロダクトの入口として、何か・どう始めるか・どこを読めばよいかを整理して見せるサイト。"
                , feature "ドキュメントと learning" "理解のために読む人へ向けた概念ページ、導入、ネストした reference。"
                , feature "リリース面" "静的公開に強い release、changelog、rollout ページ。"
                , feature "読み物と case study" "情報の順序と余白が大事な、portfolio や editorial surface。"
                ]
            , CalloutBlock
                (callout Strong "意図的に外している領域" "dashboard、editor、authenticated app、interaction-heavy な browser software は別の runtime model を欲しがります。そこは Asterism の仕事です。")
            ]
        , namedSection
            "プロダクトの考え方"
            [ ProseBlock "Portico は、あらゆる web サイトを面倒見るためのツールではありません。狙いは、静的公開される public surface に対して、 unusually clear で、AI にも人にも扱いやすい authoring path をつくることです。"
            , FeatureGridBlock
                [ feature "最初に promise が立つ" "良い公式サイトは、最初の画面で何のプロダクトかが分かります。Portico もそこを中心に据えます。"
                , feature "次に path が見える" "Getting started、theme、publishability、reference がひとつの system として読めるべきです。"
                , feature "proof は近くに置く" "sample、release、repo は必要ですが、front door を押しのける主役ではありません。"
                , feature "静的出力まで含める" "route、metadata、多言語出力、deploy file は packaging ではなく site product の一部です。"
                ]
            ]
        , namedSection
            "合いそうなら"
            [ LinkGridBlock
                [ slugLinkCard "ここから始める" startSlug (Just "最小のサイトをつくり、authoring path を体で確認します。")
                , slugLinkCard "テーマシステム" themeSlug (Just "サイトの voice を決め、その後で細部を調整します。")
                , slugLinkCard "公開" publishabilitySlug (Just "validation と deploy-oriented output を authoring に戻します。")
                , slugLinkCard "リファレンス" referenceSlug (Just "公開モジュール群と contract rule を確認します。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリの site shape を見比べます。")
                ]
            ]
        ])

  startPage =
    withSummary
      "ひとつの import から publishable な static site へ進む最短経路。"
      (page
        startSlug
        (CustomKind "Start")
        "始める"
        [ namedSection
            "Golden path"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "リファレンス" referenceSlug (Just "内部へ降りる前に公開 surface を確認します。")
                  , slugLinkCard "テーマシステム" themeSlug (Just "デザインを hand-tune する前に voice を選びます。")
                  , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで Portico を見比べます。")
                  ]
                  (withEyebrow
                    "Authoring"
                    (hero
                      "ひとつの import から、公開ページまで。"
                      "Portico から始め、サイト構造を意味で書き、公式テーマを選び、validate して、静的出力を emit します。狙いは ceremony ではなく clarity です。")))
            , TimelineBlock
                [ timelineEntry "`Portico` から import する" "site、theme、render、validate、build をひとつの明快な入口に保ちます。" Nothing
                , timelineEntry "サイトを意味で組み立てる" "site、page、section、semantic block、navigation、route helper を使います。" Nothing
                , timelineEntry "公式テーマから入る" "palette や spacing を手でいじる前に、official theme か preset から入ります。" Nothing
                , timelineEntry "validate して emit する" "公開面として筋が通ったところで validateSite を通し、静的出力を生成します。" Nothing
                ]
            , CodeBlock
                (codeSample
                  gettingStartedCode
                  (Just "purescript")
                  (Just "最小の Portico site"))
            ]
        , namedSection
            "最初に触る API"
            [ FeatureGridBlock
                [ feature "`Portico` から始める" "個別モジュールへ降りる前に、公開 root module を使います。"
                , feature "`site` / `page` / `namedSection`" "公開情報の構造を layout markup に埋めず、値として持ちます。"
                , feature "`officialThemeWith`" "サイト全体の見た目を、theme token の層で調整します。"
                , feature "`validateSite` と `emitSite`" "diagnostics と static output を通常の authoring loop に含めます。"
                ]
            ]
        , namedSection
            "次に読む"
            [ LinkGridBlock
                [ slugLinkCard "リファレンス" referenceSlug (Just "公開モジュール群と contract rule を確認します。")
                , slugLinkCard "公開" publishabilitySlug (Just "release 前に何を検証し、何を出力するかを確認します。")
                , slugLinkCard "AI ワークフロー" aiPathSlug (Just "委譲時も同じ細い path を守ります。")
                , slugLinkCard "テーマシステム" themeSlug (Just "preset と layered customization を確認します。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで Portico の site model を比べます。")
                ]
            ]
        ])

  aiPage =
    withSummary
      "実装エージェントを narrow lane に乗せるための AI workflow。"
      (page
        aiPathSlug
        (CustomKind "AI")
        "AI ワークフロー"
        [ namedSection
            "委譲するなら、境界も一緒に守る"
            [ HeroBlock
                (withActions
                  [ linkCard "Agent quickstart" githubAgentQuickstartHref (Just "Portico を使う repo-first operational path です。")
                  , linkCard "portico-user skill" githubSkillHref (Just "消費側アプリへ Portico を組み込むための skill です。")
                  , slugLinkCard "公開" publishabilitySlug (Just "release-facing な check を委譲 packet に含めます。")
                  ]
                  (withEyebrow
                    "Agent lane"
                    (hero
                      "実装エージェントには、細い authoring lane を渡す。"
                      "Portico は、one import、semantic primitive、official theme、validation、static output までをひと続きに扱えるよう、あえて細く設計されています。")))
            , FeatureGridBlock
                [ feature "入口はひとつ" "散らばった low-level module ではなく、Portico から始めます。"
                , feature "semantic primitive を優先" "site、page、section、route helper、stable block を先に使います。"
                , feature "生の relative link を書かない" "出力 tree や mount path が変わっても、route helper に relative link を任せます。"
                , feature "publish 前に validate" "validateSite や validateLocalizedSite を gate にします。"
                ]
            , CodeBlock
                (codeSample
                  aiChecklistCode
                  Nothing
                  (Just "Delegation checklist"))
            ]
        , namedSection
            "守るべき不変条件"
            [ FeatureGridBlock
                [ feature "最初に site kind を決める" "official site、docs、release、editorial のどれかを曖昧にしません。"
                , feature "繰り返し形は primitive に戻す" "同じ custom shape が何度も出るなら、Portico の block を育てます。"
                , feature "theme は content から分ける" "見た目の判断を site model に漏らしません。"
                , feature "static-first を崩さない" "locale、metadata、route は runtime より先に real page として出力します。"
                ]
            ]
        , namedSection
            "関連リンク"
            [ LinkGridBlock
                [ slugLinkCard "始める" startSlug (Just "最小の path を先に踏みます。")
                , slugLinkCard "リファレンス" referenceSlug (Just "委譲中も public surface を見失わないためです。")
                , slugLinkCard "公開" publishabilitySlug (Just "validation と deploy metadata を packet に入れます。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで site model を比較します。")
                ]
            ]
        ])

  referencePage =
    withSummary
      "現在の公開 Portico surface、contract rule、docs map。"
      (page
        referenceSlug
        Documentation
        "リファレンス"
        [ namedSection
            "現在の public surface"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "始める" startSlug (Just "最小の supported path を先に確認します。")
                  , linkCard "GitHub" githubRepositoryHref (Just "現在の repo-first source of truth です。")
                  , linkCard "Architecture" githubArchitectureHref (Just "semantic core、theme、build、validation の分離を確認します。")
                  ]
                  (withEyebrow
                    "Current contract"
                    (hero
                      "いまの公開モジュール群は、ここです。"
                      "Portico はまだ pre-beta ですが、public surface はすでに one import path と static-site workflow を中心に整理されています。")))
            , FeatureGridBlock
                [ feature "Portico.Site" "site、page、section、block、navigation、link、locale、publish-time metadata の primitive。"
                , feature "Portico.Build" "emitSite、emitMountedSite、emitLocalizedSite などの static file emission helper。"
                , feature "Portico.Render" "renderSite、renderStaticSite、renderPage、renderStylesheet などの pure render helper。"
                , feature "Portico.Validate" "validateSite、validateLocalizedSite などの publishability diagnostics。"
                , feature "Portico.Theme" "theme token と layered customization helper。"
                , feature "Portico.Theme.Official" "official preset と officialThemeWith による controlled customization path。"
                ]
            ]
        , namedSection
            "Contract rule"
            [ FeatureGridBlock
                [ feature "Portico から import する" "pre-beta の公開面が落ち着くまでは、umbrella module を正式入口として扱います。"
                , feature "semantic block を優先する" "public-site pattern が繰り返されるなら、layout fragment ではなく semantic に戻します。"
                , feature "theme を分離する" "見た目の方向は theme layer に置き、content model に混ぜません。"
                , feature "release 前に validate する" "diagnostic を通常 workflow の一部として扱います。"
                ]
            ]
        , namedSection
            "Docs map"
            [ LinkGridBlock
                [ linkCard "Vision" githubVisionHref (Just "Portico がなぜ存在するか、どこまでを対象にするか。")
                , linkCard "Architecture" githubArchitectureHref (Just "semantic core、theme、build、validation、optional islands の分離。")
                , linkCard "Agent quickstart" githubAgentQuickstartHref (Just "実装エージェント向けの repo-first path。")
                , linkCard "Deployment guide" githubDeploymentHref (Just "GitHub Pages と base URL の公開フロー。")
                , linkCard "Distribution note" githubDistributionHref (Just "repo-first の現状と package distribution の後回し理由。")
                , linkCard "Release checklist" githubReleaseChecklistHref (Just "pre-beta release gate と publication checklist。")
                ]
            ]
        ])

  themePage =
    withSummary
      "official preset と layered customization の組み立て方。"
      (page
        themeSlug
        Documentation
        "テーマシステム"
        [ namedSection
            "voice を選び、そのあとで調整する"
            [ HeroBlock
                (withActions
                  [ collectionLinkCard "プリセットカタログ" presetCatalogPath (Just "細かな調整の前に、サイトの意図から theme を選びます。")
                  , collectionLinkCard "サンプルラボ" labHomePath (Just "real sample surface 上で official theme を見比べます。")
                  , slugLinkCard "始める" startSlug (Just "まず 1 site を組んでから customization surface を広げます。")
                  ]
                  (withEyebrow
                    "Themes"
                    (hero
                      "theme は loose variable ではなく、voice から始める。"
                      "Portico の official theme system は directional preset を先に置き、そのあとで palette、typography、spacing、surface、radius、shadow を段階的に調整します。")))
            , FeatureGridBlock
                [ feature "SignalPaper" "docs や official project surface に向く、静かな標準。"
                , feature "CopperLedger" "studio、portfolio、case study に向く、少し暖かく締まった voice。"
                , feature "NightCircuit" "launch、technical announcement、event に向く、広く暗い voice。"
                , feature "BlueLedger" "notebook、essay、publication に向く、細めの editorial voice。"
                ]
            , CodeBlock
                (codeSample
                  themeCode
                  (Just "purescript")
                  (Just "official theme の layered customization"))
            ]
        , namedSection
            "何を clean に変えられるか"
            [ FeatureGridBlock
                [ feature "Accent / palette" "brand color だけを寄せることも、full palette を差し替えることもできます。"
                , feature "Typography" "render markup を壊さず、display / body / mono font を切り替えられます。"
                , feature "Spacing" "density と page rhythm を theme token の層で調整できます。"
                , feature "Surface / chrome" "frame width、pill shape、header、hero surface を content value から分けて扱えます。"
                ]
            , CalloutBlock
                (callout Quiet "公式サイト自身も同じ system 上にある" "Portico の公式サイトも、ライブラリの外側で別 CSS を書くのではなく、official theme system の上に載せています。")
            ]
        , namedSection
            "実例で見る"
            [ LinkGridBlock
                [ collectionLinkCard "プリセットカタログ" presetCatalogPath (Just "preset と customization path をひとつの chooser で比較します。")
                , collectionLinkCard "Northline Docs" docsSamplePath (Just "落ち着いた docs-facing voice を確認します。")
                , collectionLinkCard "Northstar Cloud" productSamplePath (Just "official system を product landing に寄せた例です。")
                , collectionLinkCard "Mina Arai" profileSamplePath (Just "profile と case study への適用例です。")
                , collectionLinkCard "Signal Summit" summitSamplePath (Just "event-oriented な darker voice を確認します。")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "validation、metadata、多言語出力、deploy-oriented output を含む publishability のページ。"
      (page
        publishabilitySlug
        Documentation
        "公開"
        [ namedSection
            "bundle ではなく site として公開する"
            [ HeroBlock
                (withActions
                  [ linkCard "Deployment guide" githubDeploymentHref (Just "GitHub Pages 向けの publishing path です。")
                  , slugLinkCard "Release 0.1.0" releaseSlug (Just "いまの shipped slice と、まだ動いている部分を確認します。")
                  , slugLinkCard "AI ワークフロー" aiPathSlug (Just "release-facing な check を delegated workflow に入れます。")
                  ]
                  (withEyebrow
                    "Publishability"
                    (hero
                      "publishability を authoring の外へ追い出さない。"
                      "route、summary、metadata、locale variant、static host 向け output は site product の一部です。Portico はそれらを同じ authoring loop の中に戻します。")))
            , FeatureGridBlock
                [ feature "構造と route の診断" "missing index、duplicate path、duplicate section id、broken internal link を見つけます。"
                , feature "content quality の診断" "summary が弱い、label が空、hero の置き方が不自然、といった公開面の弱さを拾います。"
                , feature "metadata と locale output" "canonical、social metadata、lang、hreflang を site model から導きます。"
                , feature "deploy-oriented file" "shared CSS、404.html、robots.txt、sitemap.xml、localized static route を出力します。"
                ]
            , TimelineBlock
                [ timelineEntry "site model を書く" "public structure、metadata、locale variant を site definition に持たせます。" Nothing
                , timelineEntry "validate する" "validateSite や validateLocalizedSite を release gate にします。" Nothing
                , timelineEntry "render / emit する" "clean な output path、shared stylesheet、relative link、static asset を生成します。" Nothing
                , timelineEntry "deploy する" "base URL を与え、Pages 向け output を build して static host へ載せます。" Nothing
                ]
            ]
        , namedSection
            "多言語の静的出力"
            [ CodeBlock
                (codeSample
                  localizedCode
                  (Just "purescript")
                  (Just "localized static publishing"))
            , FaqBlock
                [ faqEntry "render に base URL は必須ですか?" "必須ではありません。base URL が必要になるのは canonical や social URL、sitemap.xml のような deploy-oriented output を出したいときです。"
                , faqEntry "Portico で多言語サイトを作れますか?" "作れます。想定しているのは、locale ごとに real page を emit する static-first なやり方です。言語切替は link-based に保ちます。"
                , faqEntry "Portico は static CMS を目指していますか?" "いいえ。対象は、強い情報設計を持つ authored static surface であって、content-management product ではありません。"
                , faqEntry "publishability は HTML だけの話ですか?" "違います。CSS asset、canonical / social metadata、localized alternate、static-host helper file まで含みます。"
                ]
            ]
        , namedSection
            "次に読む"
            [ LinkGridBlock
                [ slugLinkCard "リファレンス" referenceSlug (Just "publish path を支える公開 module を確認します。")
                , slugLinkCard "AI ワークフロー" aiPathSlug (Just "validation と deploy concern を委譲 packet に含めます。")
                , linkCard "Deployment guide" githubDeploymentHref (Just "GitHub Pages 向けの publishing flow です。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで output story を見比べます。")
                ]
            ]
        ])

  releasePage =
    withSummary
      "Portico の最初の practical slice。"
      (page
        releaseSlug
        ReleaseNotes
        "リリース 0.1.0"
        [ namedSection
            "Release 0.1.0"
            [ HeroBlock
                (withActions
                  [ linkCard "GitHub" githubRepositoryHref (Just "repo、changelog、issue を確認します。")
                  , collectionLinkCard "サンプルラボ" labHomePath (Just "library を圧力テストする proof surface を見ます。")
                  , linkCard "Distribution note" githubDistributionHref (Just "repo-first posture と package release を後ろに置く理由です。")
                  ]
                  (withEyebrow
                    "Status"
                    (hero
                      "Portico は public pre-beta です。"
                      "semantic site model、official theme system、validation layer、localized output、GitHub Pages-oriented build path はすでに live です。一方で package distribution と最終的な public contract はまだ調整中です。")))
            , FeatureGridBlock
                [ feature "semantic site DSL" "public surface のための site、page、section、navigation、metadata、pressure-tested block primitive。"
                , feature "official theme system" "directional preset と layered customization による visual system。"
                , feature "publishability と build" "validation、canonical / social metadata、localized bundle、Pages-style output が repo に入っています。"
                , feature "dogfooded proof surface" "公式サイトと mounted sample lab の両方を Portico で emit しています。"
                ]
            , CalloutBlock
                (callout Strong "このリリースの意味" "Portico は local checkout から本気で評価できる段階です。ただし、registry package のような安定性や配布姿勢まではまだ約束していません。")
            ]
        , namedSection
            "何が入ったか"
            [ FeatureGridBlock
                [ feature "静的サイトの基礎" "relative link、shared CSS、asset、canonical metadata、static file emission。"
                , feature "多言語の公開" "英語 root と日本語 /ja/ をひとつの localized bundle から出力します。"
                , feature "validator の基礎" "path collision、broken route、weak summary、misplaced hero などの publishability concern を診断します。"
                , feature "pressure-test gallery" "6 個の sample site と preset catalog で model の弱点をあぶり出します。"
                ]
            ]
        , namedSection
            "次に強くするもの"
            [ TimelineBlock
                [ timelineEntry "validator を深くする" "publishability baseline を超えて、release confidence をもっと支える diagnostics へ広げます。" Nothing
                , timelineEntry "asset story を太くする" "最初の shared stylesheet を超えて、publish-time asset model を育てます." Nothing
                , timelineEntry "official theme を鋭くする" "Portico の出力がもっと intentional に見えるよう、公式 visual default を強くします。" Nothing
                , timelineEntry "sample lab でさらに圧をかける" "site vocabulary の弱点が見える sample を増やし、public surface を磨きます。" Nothing
                ]
            , LinkGridBlock
                [ linkCard "Release checklist" githubReleaseChecklistHref (Just "pre-beta release gate と publication checklist です。")
                , linkCard "Distribution note" githubDistributionHref (Just "repo-first の現在地と package distribution の将来です。")
                , slugLinkCard "公開" publishabilitySlug (Just "validation と deploy-facing output の側面を確認します。")
                , slugLinkCard "テーマシステム" themeSlug (Just "今後もっと強くしたい design layer です。")
                ]
            ]
        ])
