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
  , withNavigation
  , withLocale
  , withSiteLabels
  , withSummary
  )

officialSiteJa :: Site
officialSiteJa =
  withLocale japaneseLocale
    (withSiteLabels japaneseSiteLabels
      (withNavigation
        [ slugNavItem "用途" learnSlug
        , slugNavItem "始める" startSlug
        , slugNavItem "AI" aiPathSlug
        , slugNavItem "リファレンス" referenceSlug
        , collectionNavItem "ラボ" labHomePath
        , navItem "GitHub" githubRepositoryHref
        ]
          (withDescription
            "PureScriptで公開サイトを組み立てる DSL。"
            (site
              "Portico"
              [ homePage
              , learnPage
              , startPage
              , aiPathPage
              , referencePage
              , themePage
              , publishabilityPage
              , releasePage
              ]))))
  where
  learnSlug = "learn/fit"

  startSlug = "guide/getting-started"

  aiPathSlug = "guide/ai-path"

  referenceSlug = "reference/public-surface"

  themeSlug = "guide/theme-system"

  publishabilitySlug = "guide/publishability"

  releaseSlug = "releases/0-1-0"

  labHomePath = "lab/index.html"

  presetCatalogPath = "lab/presets.html"

  githubRepositoryHref = "https://github.com/M-simplifier/portico"

  githubAgentQuickstartHref = githubRepositoryHref <> "/blob/main/docs/agent-quickstart.md"

  githubSkillHref = githubRepositoryHref <> "/blob/main/skills/portico-user/SKILL.md"

  githubDeploymentHref = githubRepositoryHref <> "/blob/main/docs/deployment.md"

  githubDistributionHref = githubRepositoryHref <> "/blob/main/docs/distribution.md"

  githubReleaseChecklistHref = githubRepositoryHref <> "/blob/main/docs/release-checklist.md"

  homePage =
    withSummary
      "PureScriptで公開サイトをつくるための、サイト DSL、公式テーマ、公開前チェックの道筋。"
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "概要"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "向くサイトを見る" learnSlug (Just "Portico がどんな公開サイトに向いているかを確かめます。")
                  , slugLinkCard "最短経路で始める" startSlug (Just "ひとつの import から、公開できる静的出力まで進みます。")
                  , slugLinkCard "AI 向けガイドを見る" aiPathSlug (Just "実装エージェントに任せるときの、細い導入経路を確認します。")
                  ]
                  (withEyebrow
                    "公開サイト"
                    (hero
                      "PureScriptで、公開サイトをつくる。"
                      "Porticoは、ドキュメント、リリース、ポートフォリオ、エッセイなどの公開サイトに向けて、意味のあるサイト構造、公式テーマ、静的公開までの流れをひとつにまとめます。Asterismの軽量版ではなく、アプリケーションの土台をつくるためのものでもありません。")))
            , FeatureGridBlock
                [ feature "意味のあるサイト構造" "公開情報の組み立ては、場当たり的なレイアウトではなく `site`、`page`、`section`、ブロックで表します。"
                , feature "公式テーマ" "まずは読みやすさとサイトの姿勢から入り、必要なぶんだけ段階的に調整します。"
                , feature "公開前チェック" "ルート、要約、メタデータ、出力形状を確かめてから、サイト定義を公開物として扱います。"
                , feature "いまの公開契約" "プレベータの現在地は、公式サイト、サンプルラボ、リポジトリ文書にあります。"
                ]
            ]
        , namedSection
            "進め方を選ぶ"
            [ LinkGridBlock
                [ slugLinkCard "向くサイトを見る" learnSlug (Just "カテゴリ適合、スコープ、Portico と Asterism の境界から始めます。")
                , slugLinkCard "始め方を見る" startSlug (Just "ひとつの import から、最小の検証済みサイトへ進みます。")
                , slugLinkCard "AI と使う" aiPathSlug (Just "実装エージェントへサイト作業を委ねるときの運用経路を見ます。")
                , slugLinkCard "リファレンスを読む" referenceSlug (Just "サポートしているモジュール群、運用ルール、文書マップを確認します。")
                ]
            ]
        , namedSection
            "作例で確かめる"
            [ CalloutBlock
                (callout Quiet "補助資料" "用途と対応済みの道筋が見えたら、サンプルラボとプリセットカタログで、表現の幅と見た目の方向を確かめます。")
            , LinkGridBlock
                [ collectionLinkCard "サンプルラボを見る" labHomePath (Just "ドキュメント、プロダクト、ポートフォリオ、プロフィール、イベント、出版系の作例を横断して見比べられます。")
                , collectionLinkCard "プリセットカタログを見る" presetCatalogPath (Just "細かな調整に入る前に、サイトの意図と読み味からテーマを選びます。")
                , slugLinkCard "テーマシステムを見る" themeSlug (Just "プリセットと段階的なカスタマイズの関係を確認します。")
                , slugLinkCard "公開前チェックを見る" publishabilitySlug (Just "検証、メタデータ、静的出力、公開向けファイルを確認します。")
                ]
            ]
        , namedSection
            "現在のリリース"
            [ CalloutBlock
                (callout Quiet "プレベータ / リポジトリ起点" "Portico はすでに公開済みですが、契約はまだ固まり切っていません。いまの真実は、リポジトリ、公式サイト、`npm run verify` です。")
            , LinkGridBlock
                [ slugLinkCard "リリース 0.1.0 を読む" releaseSlug (Just "いま使えるものと、まだ動いているものを整理して見ます。")
                , linkCard "GitHub を開く" githubRepositoryHref (Just "コード、文書、課題、リリース姿勢の現在地としてリポジトリを使います。")
                , linkCard "デプロイガイドを読む" githubDeploymentHref (Just "GitHub Pages 向けの base URL と公開フローを確認します。")
                ]
            ]
        ])

  learnPage =
    withSummary
      "Portico がどんな公開サイトに向いているかを判断するためのページ。"
      (page
        learnSlug
        (CustomKind "用途")
        "Porticoが向くサイト"
        [ namedSection
            "どんなカテゴリか"
            [ ProseBlock "Portico は、静的出力としてきれいに公開したいサイトのためのライブラリです。公式プロジェクトサイト、ドキュメント、リリースページ、ポートフォリオ、エッセイ、小規模なイベントやキャンペーンサイトのように、公開サイトの情報設計が重要な場面に向いています。"
            , FeatureGridBlock
                [ feature "公式サイト" "プロジェクトの入口、安定した説明導線、読みやすいリリース面が必要なときに使います。"
                , feature "ドキュメントとガイド" "概念ページ、導入フロー、API 周辺の案内、リリース隣接の情報を、アプリシェルにせずまとめられます。"
                , feature "リリースと読み物" "チェンジログ、エッセイ、ノート、その他の読み物中心の公開物に向いています。"
                , feature "ポートフォリオと特設サイト" "ケーススタディやイベント系の落ち着いたサイトにも向いています。相互作用の密度より情報設計が大事だからです。"
                ]
            , CalloutBlock
                (callout Strong "Asterismの軽量版ではない" "長く生きる状態、認証、重い相互作用、ブラウザソフトウェア寄りの挙動が必要なら、設計の中心はすでに Portico の外です。")
            ]
        , namedSection
            "どう考えるか"
            [ FeatureGridBlock
                [ feature "構造から書く" "公開モデルは、生の HTML 断片ではなく、site、page、section、block、navigation、route helper から始まります。"
                , feature "見た目はテーマに分ける" "デザイントークン、読み味、余白、クロームはテーマ層に置き、コンテンツモデルへ漏らしません。"
                , feature "静的出力を前提にする" "レンダリング、検証、メタデータ、ファイル出力は、アプリ実行時ではなく静的公開に向けて設計されています。"
                , feature "相互作用より情報設計" "中心にあるのは、公開サイトでの説明、順序、導線であって、細かなマイクロインタラクションではありません。"
                ]
            , CalloutBlock
                (callout Accent "この形にする理由" "人間も AI も、毎回レイアウト断片から再発明するのではなく、公開サイトの構造に同じ入口から入れるようにするためです。")
            ]
        , namedSection
            "向いていないもの"
            [ FeatureGridBlock
                [ feature "運用ダッシュボード" "運用コンソールは、密な状態、フィルタ、相互作用のループが必要で、Portico の中心から外れます。"
                , feature "エディタ" "執筆・編集ソフトウェアには、公開時の静的出力とは別の実行モデルが必要です。"
                , feature "認証付きアプリ" "アイデンティティ、セッション、非公開状態が核なら、Portico は抽象の境界として合いません。"
                , feature "相互作用の重いブラウザソフト" "サイトがまずソフトウェアで、公開面はその次になるなら、問題は Asterism 側へ寄せるべきです。"
                ]
            ]
        , namedSection
            "合いそうなら"
            [ LinkGridBlock
                [ slugLinkCard "最短経路で始める" startSlug (Just "用途の確認から、最小の執筆経路へ進みます。")
                , slugLinkCard "AI 向けガイドを見る" aiPathSlug (Just "リポジトリ起点で、エージェント向けの導入経路を確認します。")
                , slugLinkCard "リファレンスを読む" referenceSlug (Just "サポートしているモジュール群と運用ルールを確認します。")
                , slugLinkCard "テーマシステムを見る" themeSlug (Just "まずプリセットを選び、その後で段階的にカスタマイズします。")
                , slugLinkCard "公開前チェックを見る" publishabilitySlug (Just "検証と静的出力の側面を確認します。")
                , collectionLinkCard "サンプルラボを見る" labHomePath (Just "用途が見えたあとに、より広い作例面を見比べます。")
                ]
            ]
        ])

  startPage =
    withSummary
      "ひとつの import から、公開できる静的出力へ最短で進むための道筋。"
      (page
        startSlug
        (CustomKind "導入")
        "始める"
        [ namedSection
            "基本の道筋"
            [ TimelineBlock
                [ timelineEntry "1. `Portico` から始める" "site、theme、render、validate、build の対応済みファミリーを、ひとつの分かりやすい入口に保てます。" Nothing
                , timelineEntry "2. サイトを意味で組み立てる" "生の HTML 断片ではなく、`site`、`page`、`section`、セマンティックなブロック、navigation、route helper を使います。" Nothing
                , timelineEntry "3. 公式テーマから入る" "独自のタイポグラフィや余白に手を入れる前に、`officialTheme` か公式プリセットから始めます。" Nothing
                , timelineEntry "4. 検証して出力する" "公開サイトとして筋が通ったところで `validateSite` を通し、静的出力をレンダリングまたは生成します。" Nothing
                ]
            , CalloutBlock
                (callout Accent "対応済みの道筋に留まる" "同じ形が何度も現れるなら、一点物のマークアップを増やすのではなく Portico のプリミティブを育てます。")
            ]
        , namedSection
            "最小サイト"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nsiteDefinition =\n  site \"Signal Manual\"\n    [ withSummary\n        \"落ち着いたドキュメントの入口。\"\n        (page \"index\" Landing \"Signal Manual\"\n          [ namedSection \"イントロ\"\n              [ HeroBlock\n                  (hero\n                    \"PureScriptで公開サイトをつくる。\"\n                    \"意味のある道筋に乗る。\")\n              ]\n          ])\n    ]\n\nmain = do\n  let report = validateSite siteDefinition\n  emitSite \"site/dist\" officialTheme siteDefinition"
                  (Just "purescript")
                  (Just "ひとつの import、ひとつのサイト、ひとつの検証済みビルド経路"))
            ]
        , namedSection
            "最初に触るもの"
            [ FeatureGridBlock
                [ feature "`Portico` から import する" "個別のモジュールに降りる前に、統合モジュールから始めます。"
                , feature "`officialTheme`" "まずは落ち着いた標準から入り、必要になってからプリセットや段階的カスタマイズへ進みます。"
                , feature "`validateSite`" "公開前の診断を、任意の飾りではなく、対応済みの執筆ループの一部として扱います。"
                , feature "`emitSite` / `emitMountedSite`" "サイト構造と相対パスの準備ができたら、きれいな静的出力を生成します。"
                ]
            ]
        , namedSection
            "次に読む"
            [ LinkGridBlock
                [ slugLinkCard "リファレンスを読む" referenceSlug (Just "サポートしているモジュール群と運用ルールを確認します。")
                , slugLinkCard "AI 向けガイドを見る" aiPathSlug (Just "作業をエージェントへ委ねるときの、より細い導入経路です。")
                , slugLinkCard "テーマシステムを見る" themeSlug (Just "プリセット選択と段階的カスタマイズの考え方を確認します。")
                , slugLinkCard "公開前チェックを見る" publishabilitySlug (Just "公開前に Portico が何を検証し、何を出力するかを見ます。")
                , collectionLinkCard "サンプルラボを見る" labHomePath (Just "最小経路が見えたあとに、より広い圧力テスト面を比較します。")
                ]
            ]
        ])

  aiPathPage =
    withSummary
      "サイト制作を AI に委ねるときの基本経路。"
      (page
        aiPathSlug
        (CustomKind "AI")
        "AI 導入"
        [ namedSection
            "AI に任せるとき"
            [ HeroBlock
                (withActions
                  [ linkCard "Agent Quickstart を開く" githubAgentQuickstartHref (Just "標準の AI 向け実装経路を説明するリポジトリ文書を読みます。")
                  , slugLinkCard "サポート範囲を見る" referenceSlug (Just "タスクを広げる前に、対応しているモジュール群と運用ルールを確認します。")
                  , linkCard "導入 skill を開く" githubSkillHref (Just "消費側アプリに Portico を組み込むための、リポジトリ起点の導入 skill を見ます。")
                  ]
                  (withEyebrow
                    "AI 向けの経路"
                    (hero
                      "Porticoは、委譲しやすい形で作られている。"
                      "Portico を評価する人の多くは、実装エージェントが無理なく扱えるかを見ています。そこで Portico は、`Portico` からの import、セマンティックなサイトプリミティブ、公式テーマ、検証、静的出力までを、あえて細く保っています。")))
            ]
        , namedSection
            "対応している運用形"
            [ FeatureGridBlock
                [ feature "入口がひとつ" "エージェントは、散らばった低レベルモジュールではなく `Portico` から始めるべきです。"
                , feature "意味のあるプリミティブ" "執筆面がサイト上の役割を直接名指しすることで、生のレイアウト断片への逸脱を抑えます。"
                , feature "公式テーマの道筋" "強いデフォルトと明示的なプリセットで、委譲作業時の見た目の曖昧さを下げます。"
                , feature "公開前の検証" "出力を許容する前に、ルート、要約、構造を確認できます。"
                , feature "静的ビルド" "レンダリングとファイル出力は、公開ホスティング向けに決定的かつサブパス安全に保たれます。"
                , feature "リポジトリ起点の導入" "現時点で最も安全なのは、明示的な文書と可視な公開サーフェスを伴うソース先行の導入です。"
                ]
            ]
        , namedSection
            "エージェントに伝えること"
            [ CodeBlock
                (codeSample
                  "公開サイトには Portico を使う。\n`Portico` から import する。\nセマンティックなサイトプリミティブを優先する。\nテーマの関心事はコンテンツモデルと分ける。\n`officialTheme` か `officialThemeWith*` を使う。\n公開前に `validateSite` を通す。\n`emitSite` か `emitMountedSite` で静的出力する。"
                  (Just "text")
                  (Just "実装エージェント向けの最小タスクパケット"))
            , CalloutBlock
                (callout Quiet "プレベータの姿勢" "当面は、ローカル checkout と明示的な公開サーフェスを前提に、リポジトリ起点で導入するのが安全です。")
            ]
        , namedSection
            "運用上の参照"
            [ LinkGridBlock
                [ linkCard "Agent Quickstart" githubAgentQuickstartHref (Just "標準の AI 向け実装経路を説明するリポジトリ文書です。")
                , linkCard "portico-user skill" githubSkillHref (Just "Portico を消費側アプリへ配線するためのリポジトリ起点 skill です。")
                , slugLinkCard "サポート範囲" referenceSlug (Just "公式サイト上の対応済みモジュール群と運用ルールです。")
                , slugLinkCard "公開前チェック" publishabilitySlug (Just "契約の検証、メタデータ、静的出力の側面です。")
                , linkCard "配布メモ" githubDistributionHref (Just "現在のリポジトリ起点の姿勢と、あとで package 化する分配方針です。")
                , linkCard "GitHub を開く" githubRepositoryHref (Just "公開リポジトリを現在の真実として使います。")
                ]
            ]
        ])

  referencePage =
    withSummary
      "現在サポートしている Portico のモジュール群、運用ルール、関連ドキュメント。"
      (page
        referenceSlug
        (CustomKind "リファレンス")
        "サポート範囲"
        [ namedSection
            "いま使えるモジュール"
            [ FeatureGridBlock
                [ feature "Portico.Site" "site、page、section、block、navigation、link、公開時メタデータのプリミティブ。"
                , feature "Portico.Build" "`emitSite` や `emitMountedSite` などの静的ファイル出力 helper。"
                , feature "Portico.Render" "`renderSite`、`renderStaticSite`、`renderPage`、`renderStylesheet` などの純粋なレンダリング helper。"
                , feature "Portico.Validate" "`validateSite`、`siteDiagnostics`、`hasErrors` などの公開前診断。"
                , feature "Portico.Theme" "テーマトークンと段階的カスタマイズの helper。"
                , feature "Portico.Theme.Official" "公式プリセットと `officialThemeWith*` のカスタマイズ経路。"
                ]
            ]
        , namedSection
            "運用ルール"
            [ FeatureGridBlock
                [ feature "`Portico` から import する" "プレベータの公開面が落ち着くまでは、統合モジュールを意図された公開入口として扱います。"
                , feature "意味のあるプリミティブを優先する" "同じパターンが繰り返されるなら、生のマークアップを散らすのではなくドメインブロックを追加・改良します。"
                , feature "テーマは分けて考える" "見た目の選択は、ページモデルではなくテーマ層に置きます。"
                , feature "ルートヘルパーを優先する" "内部の相対パスを手で書く代わりに、site と collection の helper を使います。"
                , feature "`validateSite` を通す" "リリース前の対応済みワークフローの一部として、公開前診断を扱います。"
                ]
            ]
        , namedSection
            "関連ドキュメント"
            [ LinkGridBlock
                [ slugLinkCard "向くサイトを見る" learnSlug (Just "カテゴリ適合、スコープ、Portico と Asterism の境界を確認します。")
                , slugLinkCard "始め方を見る" startSlug (Just "import から出力までの最短の対応済み経路です。")
                , slugLinkCard "AI 導入を見る" aiPathSlug (Just "委譲実装のための、より細いリポジトリ起点の経路です。")
                , slugLinkCard "テーマシステム" themeSlug (Just "プリセット選択と段階的カスタマイズです。")
                , slugLinkCard "公開前チェック" publishabilitySlug (Just "検証、メタデータ、静的出力、公開向けファイルです。")
                , slugLinkCard "リリース 0.1.0" releaseSlug (Just "いま使えるものと、まだ動いているものを確認します。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "ドキュメント、プロダクト、ポートフォリオ、プロフィール、イベント、出版系の広い作例面です。")
                , linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages 向けの build と base URL の流れです。")
                , linkCard "リリースチェックリスト" githubReleaseChecklistHref (Just "現在のリポジトリ起点の公開ゲートとチェックリストです。")
                ]
            ]
        , namedSection
            "まだ動いているもの"
            [ CalloutBlock
                (callout Quiet "プレベータの契約" "ブロック語彙、検証の深さ、最初の stylesheet を越えたアセットの扱い、将来のパッケージ分割は、いまも調整中です。")
            ]
        ])

  themePage =
    withSummary
      "公式プリセットと段階的なカスタマイズの関係。"
      (page
        themeSlug
        Documentation
        "テーマシステム"
        [ namedSection
            "選び方"
            [ ProseBlock "最初に考えるのはアクセントカラーではなく、どんなサイトとして読ませたいかです。公式システムは、短い時間で筋の通った公開サイトをつくれるだけの意見を持つように設計されています。"
            , FeatureGridBlock
                [ feature "意図から選ぶ" "色やタイポグラフィを調整する前に、ドキュメント、スタジオ、ローンチ、出版といった姿勢を選びます。"
                , feature "段階的に重ねる" "accent、palette、typography、spacing、surface、radius、shadow は、公式システムを置き換えるのではなく、その上に重ねます。"
                , feature "DSL は意味ベースのままにする" "テーマの詳細はテーマ層に属し、ページモデルに混ぜません。"
                ]
            ]
        , namedSection
            "公式プリセット"
            [ FeatureGridBlock
                [ feature "SignalPaper" "公式ドキュメントやプロジェクトサイトに向いた、落ち着いた標準。"
                , feature "CopperLedger" "より引き締まり、やや暖色寄りのスタジオ / ポートフォリオ向けの声。"
                , feature "NightCircuit" "広めで暗めの、技術系ローンチやイベント向けの声。"
                , feature "BlueLedger" "より細身で、出版物やノート向けの声。"
                ]
            ]
        , namedSection
            "カスタマイズの階段"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nlaunchTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#0f766e\"\n      , spacing = Just\n          { pageInset: \"3.2rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"5.6rem\"\n          , sectionGap: \"3.2rem\"\n          , stackGap: \"1.3rem\"\n          , cardPadding: \"1.4rem\"\n          , heroPadding: \"2.35rem\"\n          }\n      })"
                  (Just "purescript")
                  (Just "公式テーマをカスタマイズするための、ひとつの入口"))
            , CalloutBlock
                (callout Quiet "補助資料" "プリセットカタログは、サイトのカテゴリが見えてから使います。最初の判断材料ではなく、裏付けとして使うものです。")
            , LinkGridBlock
                [ collectionLinkCard "プリセットカタログを見る" presetCatalogPath (Just "プリセットが生成サンプル面にどう対応するかを確認します。")
                , collectionLinkCard "サンプルラボを比較する" labHomePath (Just "複数のサイトカテゴリをまたいで、公式テーマシステムを確かめます。")
                , slugLinkCard "始め方へ戻る" startSlug (Just "テーマを選ぶあいだも、対応済みの執筆経路を見失わないようにします。")
                , slugLinkCard "リファレンスへ戻る" referenceSlug (Just "カスタマイズしながら、サポート範囲を再確認します。")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "公開前の検証、ビルド出力、公開向けメタデータ。"
      (page
        publishabilitySlug
        Documentation
        "公開前チェック"
        [ namedSection
            "Portico が見ること"
            [ FeatureGridBlock
                [ feature "最初に検証する" "公開前に、index の欠落、重複パス、壊れた内部ルート、弱い要約、誤った hero 配置を確認します。"
                , feature "モデルからメタデータを出す" "canonical、OG、Twitter の各タグは、生の head マークアップではなく site と page の値から導きます。"
                , feature "多言語サイトを静的に出す" "複数言語のサイトでも、`lang`、言語切替ルート、`hreflang` を、実際の静的ページとして出力できます。クライアント側アプリに寄せる必要はありません。"
                , feature "サブパスに強い静的出力" "ネストしたルート、共有 CSS アセット、mounted collection の下でも崩れにくいファイルを出力します。"
                , feature "Pages 向けファイル" "GitHub Pages 向けの出力でも、`404.html`、`robots.txt`、`sitemap.xml` を DSL に混ぜ込まずに扱えます。"
                ]
            ]
        , namedSection
            "公開までの流れ"
            [ TimelineBlock
                [ timelineEntry "確認する" "ページモデルがまだ動いている間は、`renderSite` で素早く確認したりインラインプレビューしたりできます。" Nothing
                , timelineEntry "検証する" "サイト定義を公開可能とみなす前のゲートとして `validateSite` を使います。" Nothing
                , timelineEntry "多言語化する" "言語切替が必要なときは、ランタイムの状態に寄せるのではなく、言語別サイトをひとつの静的サイト群として束ねます。" Nothing
                , timelineEntry "出力する" "静的ホスティングに載せる準備ができたら `emitSite`、`emitMountedSite`、`emitLocalizedSite` を使います。" Nothing
                , timelineEntry "公開に寄せる" "実際の公開物として扱う段階で、base URL と公開向けファイルを足します。" Nothing
                ]
            , CodeBlock
                (codeSample
                  "import Portico\n\nreport = validateLocalizedSite localizedDefinition\nsiteHasErrors = hasLocalizedErrors localizedDefinition\n\nmain =\n  emitLocalizedSite \"site/dist\" officialTheme localizedDefinition"
                  (Just "purescript")
                  (Just "多言語サイトを、検証してから出力する"))
            ]
        , namedSection
            "よくある質問"
            [ FaqBlock
                [ faqEntry "レンダリング時に base URL は必須ですか?" "いいえ。base URL が必要になるのは canonical と social metadata を出したいときで、ローカル確認の段階では不要です。"
                , faqEntry "静的サイトを多言語化できますか?" "できます。Portico が想定しているのは、言語ごとに実際のページを出力する静的ファーストなやり方です。言語切替はリンクベースで行い、`lang` や alternate metadata はビルド側が担当します。"
                , faqEntry "相対リンクは手で書くべきですか?" "ネストした出力でも崩れないように、route helper と mounted collection helper を優先してください。"
                , faqEntry "公開前の定番チェックは何ですか?" "`npm run verify` を使います。テストに加えて、単体の sample-lab、official-site、GitHub Pages 向け build 出力までまとめて確認します。"
                , faqEntry "Portico は静的 CMS を目指していますか?" "いいえ。対象は、情報設計の強い公開サイトであって、コンテンツ管理ツールではありません。"
                ]
            ]
        , namedSection
            "公開向けドキュメント"
            [ LinkGridBlock
                [ slugLinkCard "リファレンスを読む" referenceSlug (Just "サポートしているモジュール群と運用ルールへ戻ります。")
                , slugLinkCard "AI 向けガイドを見る" aiPathSlug (Just "委ねた執筆経路を、公開前チェックの契約に揃えます。")
                , linkCard "デプロイガイドを読む" githubDeploymentHref (Just "GitHub Pages 向けの build と base URL の流れを確認します。")
                , linkCard "リリースチェックリストを読む" githubReleaseChecklistHref (Just "リポジトリ起点の公開ゲートとチェックリストを見ます。")
                ]
            ]
        ])

  releasePage =
    withSummary
      "Portico の最初の実用スライス。"
      (page
        releaseSlug
        ReleaseNotes
        "リリース 0.1.0"
        [ namedSection
            "いま使えるもの"
            [ FeatureGridBlock
                [ feature "型付きのサイトモデル" "公開サイトのための site、page、section、navigation、route、block の語彙は、すでに揃っています。"
                , feature "公式テーマシステム" "公式プリセット経路、段階的カスタマイズ、プリセットカタログはすでに利用できます。"
                , feature "公開前チェックとビルド" "検証、canonical / social metadata、静的出力、多言語サイト、GitHub Pages 向け出力は、リポジトリ起点の切り出しに含まれています。"
                , feature "公式サイトとサンプルラボ" "公式サイトと幅広いサンプルラボが、そのまま公開オンボーディングとして動いています。"
                ]
            ]
        , namedSection
            "いまの姿勢"
            [ CalloutBlock
                (callout Strong "状態" "Portico は公開プレベータです。公式サイト、リポジトリ文書、サンプルラボ、検証フロー、GitHub Pages ビルドはすでに動いています。一方で、パッケージ配布と最終的な契約の細部はまだ調整中です。")
            ]
        , namedSection
            "まだ動いているもの"
            [ FeatureGridBlock
                [ feature "ブロック語彙" "正確なセマンティックブロックの集合は、実際の公開サイト形状に対して引き続き圧力テストされます。"
                , feature "検証の深さ" "診断範囲は、最初の公開前チェックを越えて広がっていきます。"
                , feature "アセットの扱い" "最初の shared stylesheet と mounted sample assets を越えた先は、まだ意図的に開かれています。"
                , feature "パッケージ分割" "将来的な registry packaging と package metadata は、まだ意図的に後ろ倒しです。"
                ]
            ]
        , namedSection
            "次に見るもの"
            [ LinkGridBlock
                [ slugLinkCard "向くサイトを見る" learnSlug (Just "カテゴリとスコープの整理に戻ります。")
                , slugLinkCard "最短経路で始める" startSlug (Just "リリース姿勢から、具体的な執筆経路へ進みます。")
                , collectionLinkCard "サンプルラボを見る" labHomePath (Just "圧力テスト面を使って、モデルの改善点を探します。")
                , linkCard "GitHub を開く" githubRepositoryHref (Just "コード、課題、文書、現在のプレベータ姿勢を公開リポジトリで追います。")
                ]
            ]
        ])
