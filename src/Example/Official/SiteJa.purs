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
  , withSiteLabels
  , withSummary
  )

officialSiteJa :: Site
officialSiteJa =
  withSiteLabels japaneseSiteLabels
    (withNavigation
      [ slugNavItem "学ぶ" learnSlug
      , slugNavItem "始める" startSlug
      , slugNavItem "AI" aiPathSlug
      , slugNavItem "リファレンス" referenceSlug
      , collectionNavItem "ラボ" labHomePath
      , navItem "GitHub" githubRepositoryHref
      ]
        (withDescription
        "PureScript で、ドキュメント、リリース、ポートフォリオ、エッセイなどの公開静的サイトを組み立てるためのセマンティックなサイト DSL。"
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
          ])))
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
      "PureScript で公開静的サイトをつくるための、セマンティックなサイト DSL、公式テーマシステム、そして公開可能性までの道筋。"
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "概要"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Portico が合うか確認する" learnSlug (Just "必要な公開サイトの種類に Portico が合っているかを見極めます。")
                  , slugLinkCard "対応済みの道筋から始める" startSlug (Just "ひとつの import から、検証済みの静的出力まで進みます。")
                  , slugLinkCard "AI 向けの進め方を見る" aiPathSlug (Just "実装エージェントに任せるための、狭く定義された経路を確認します。")
                  ]
                  (withEyebrow
                    "公開静的サイト"
                    (hero
                      "PureScript で公開静的サイトを構築する。"
                      "Portico は、ドキュメント、リリースページ、ポートフォリオ、エッセイ、その他の公開面に対して、セマンティックなサイトモデル、公式テーマシステム、そして静的公開までの経路を用意します。これは Asterism の縮小版ではなく、アプリシェル向けでもありません。")))
            , FeatureGridBlock
                [ feature "セマンティックなサイトモデル" "公開情報アーキテクチャは、場当たり的なレイアウト断片ではなく `site`、`page`、`section`、ブロックの中に明示しておきます。"
                , feature "公式テーマシステム" "まずは色味よりも読みやすさを優先し、サイトモデルを崩さずに段階的に調整します。"
                , feature "公開可能性を最初から持つ" "ルート、要約、メタデータ、出力形状を検証してから、サイト定義を実物として扱います。"
                , feature "Repo-first の真実" "プレベータの間は、公式サイト、サンプルラボ、リポジトリ文書が現在の契約です。"
                ]
            ]
        , namedSection
            "進む道を選ぶ"
            [ LinkGridBlock
                [ slugLinkCard "適用範囲を確認する" learnSlug (Just "カテゴリー適合、スコープ、Portico と Asterism の境界から始めます。")
                , slugLinkCard "始め方を見る" startSlug (Just "ひとつの import から、最小の検証済みサイトへ進みます。")
                , slugLinkCard "AI と一緒に使う" aiPathSlug (Just "実装エージェントへサイト作業を委譲する運用経路を確認します。")
                , slugLinkCard "リファレンスを読む" referenceSlug (Just "サポート済みのファミリー、契約ルール、文書マップを見ます。")
                ]
            ]
        , namedSection
            "実際の使い方を見る"
            [ CalloutBlock
                (callout Quiet "任意の裏付け" "適合範囲と対応済みの道筋が見えたら、サンプルラボとプリセットカタログで幅と見た目の広さを検証します。")
            , LinkGridBlock
                [ collectionLinkCard "サンプルラボを見る" labHomePath (Just "ドキュメント、プロダクト、ポートフォリオ、プロフィール、イベント、出版系の各面を横断して確認できます。")
                , collectionLinkCard "プリセットカタログを開く" presetCatalogPath (Just "微調整の前に、サイトの意図と読みの姿勢からテーマを選びます。")
                , slugLinkCard "テーマシステムを詳しく見る" themeSlug (Just "プリセットと段階的なカスタマイズの関係を確認します。")
                , slugLinkCard "公開可能性を詳しく見る" publishabilitySlug (Just "検証、メタデータ、静的出力、配布向けファイルを見ます。")
                ]
            ]
        , namedSection
            "現在のリリース"
            [ CalloutBlock
                (callout Quiet "プレベータ、repo-first" "Portico は今すぐ使えますが、契約はまだ固まり切っていません。現在の真実は、リポジトリ、公式サイト、`npm run verify` です。")
            , LinkGridBlock
                [ slugLinkCard "リリース 0.1.0 を読む" releaseSlug (Just "今すぐ使えるものと、意図的に変化中のものを確認します。")
                , linkCard "GitHub リポジトリを開く" githubRepositoryHref (Just "コード、文書、課題、リリース姿勢の現在値としてリポジトリを使います。")
                , linkCard "デプロイガイドを読む" githubDeploymentHref (Just "GitHub Pages 向けの base URL と公開フローを確認します。")
                ]
            ]
        ])

  learnPage =
    withSummary
      "Portico がどんな公開サイトに合うのかを判断するためのページ。"
      (page
        learnSlug
        (CustomKind "Learn")
        "Portico の用途"
        [ namedSection
            "カテゴリー"
            [ ProseBlock "Portico は、公開された公的な面のためのものです。公式プロジェクトサイト、ドキュメント、リリースページ、ポートフォリオ、エッセイ、そして小規模なイベントやキャンペーンサイトなど、静的出力としてきれいに公開したいものに向いています。"
            , FeatureGridBlock
                [ feature "公式サイト" "プロジェクトの玄関口、安定した説明導線、読みやすいリリース面が必要なときに使います。"
                , feature "ドキュメントとガイド" "概念ページ、導入フロー、API に近いリファレンス、リリース周辺の案内に使えます。アプリシェルにはしません。"
                , feature "リリースと公開面" "チェンジログ、エッセイ、ノートブック、その他の読み物中心の成果物に合います。"
                , feature "ポートフォリオとマイクロサイト" "見せ方やケーススタディ、イベント系の落ち着いたサイトにも向いています。公開情報アーキテクチャが相互作用の密度より大事だからです。"
                ]
            , CalloutBlock
                (callout Strong "Asterism の軽量版ではない" "長寿命の状態、認証フロー、重い相互作用、ブラウザソフトウェア的な挙動が必要なら、その設計中心はすでに Portico の外です。")
            ]
        , namedSection
            "Portico の考え方"
            [ FeatureGridBlock
                [ feature "まず構造を意味で表す" "公開モデルは、生の HTML 断片ではなく、site, page, section, block, navigation, route のヘルパーから始まります。"
                , feature "テーマは分離して保つ" "デザイントークン、読みの姿勢、余白、クロームはテーマ層に置き、コンテンツモデルへ漏らしません。"
                , feature "静的ファーストのビルド" "レンダリング、検証、メタデータ、ファイル出力はすべて、アプリ実行時の都合ではなく静的出力に向いています。"
                , feature "相互作用より公開 IA" "中心にあるのは、公開面での説明、順序付け、導線であって、細かなマイクロインタラクションではありません。"
                ]
            , CalloutBlock
                (callout Accent "なぜ重要か" "人間も AI も、毎回レイアウト断片から再発見するのではなく、明示された公開サイト構造に同じ場所から入れるようにするためです。")
            ]
        , namedSection
            "向いていないもの"
            [ FeatureGridBlock
                [ feature "ダッシュボード" "運用コンソールは、密な状態、フィルタ、相互作用ループが必要で、Portico の中心から外れます。"
                , feature "エディタ" "著作・編集ソフトウェアは、公開時の静的出力とは別の実行モデルが必要です。"
                , feature "認証付きアプリ" "アイデンティティ、セッション、非公開状態が核なら、Portico は境界設定として合いません。"
                , feature "相互作用が重いブラウザソフトウェア" "サイトがまずソフトウェアで、公開面はその次になるなら、問題は Asterism 側へ寄せるべきです。"
                ]
            ]
        , namedSection
            "合うなら"
            [ LinkGridBlock
                [ slugLinkCard "対応済みの道筋から始める" startSlug (Just "適合確認から最小の執筆経路へ進みます。")
                , slugLinkCard "AI 向けの進め方を見る" aiPathSlug (Just "repo-first で、エージェント向けの導入経路を確認します。")
                , slugLinkCard "リファレンスを読む" referenceSlug (Just "対応済みのファミリーと契約ルールを確認します。")
                , slugLinkCard "テーマシステムを見る" themeSlug (Just "まずプリセットを選び、その後で段階的にカスタマイズします。")
                , slugLinkCard "公開可能性を見る" publishabilitySlug (Just "検証と静的出力の側面を確認します。")
                , collectionLinkCard "サンプルラボを見る" labHomePath (Just "適合が見えたあとに、より広い証拠面を使います。")
                ]
            ]
        ])

  startPage =
    withSummary
      "ひとつの import から、検証済みの静的出力へ最短で進むための道筋。"
      (page
        startSlug
        (CustomKind "Start")
        "始め方"
        [ namedSection
            "ゴールデンパス"
            [ TimelineBlock
                [ timelineEntry "1. `Portico` から import する" "対応済みの site, theme, render, validate, build の各ファミリーを、ひとつの分かりやすい経路に保てます。" Nothing
                , timelineEntry "2. サイトを意味でモデル化する" "生の HTML 断片ではなく、`site`、`page`、`section`、セマンティックなブロック、navigation、route のヘルパーを使います。" Nothing
                , timelineEntry "3. 公式の声を選ぶ" "カスタムのタイポグラフィ、余白、surface override に行く前に、`officialTheme` か公式プリセットから始めます。" Nothing
                , timelineEntry "4. 検証して出力する" "公開面が整合してから `validateSite` を実行し、その後に静的出力をレンダリングまたは生成します。" Nothing
                ]
            , CalloutBlock
                (callout Accent "対応済みの道筋に留まる" "同じ形が繰り返し現れるなら、一点物のマークアップを散らすのではなく、Portico のプリミティブを追加・改良します。")
            ]
        , namedSection
            "最小サイト"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nsiteDefinition =\n  site \"Signal Manual\"\n    [ withSummary\n        \"落ち着いたドキュメントの玄関口。\"\n        (page \"index\" Landing \"Signal Manual\"\n          [ namedSection \"イントロ\"\n              [ HeroBlock\n                  (hero\n                    \"PureScript で公開面をつくる。\"\n                    \"セマンティックな道筋に乗る。\")\n              ]\n          ])\n    ]\n\nmain = do\n  let report = validateSite siteDefinition\n  emitSite \"site/dist\" officialTheme siteDefinition"
                  (Just "purescript")
                  (Just "ひとつの import、ひとつのサイト、ひとつの検証済みビルド経路"))
            ]
        , namedSection
            "まず使うもの"
            [ FeatureGridBlock
                [ feature "`Portico` から import する" "個別のファミリーに降りる前に、統合モジュールから始めます。"
                , feature "`officialTheme`" "まずは落ち着いた標準から始め、必要になってからプリセットや段階的カスタマイズへ進みます。"
                , feature "`validateSite`" "公開可能性の診断を、任意の飾りではなく、対応済みの執筆ループの一部として扱います。"
                , feature "`emitSite` / `emitMountedSite`" "サイト構造と相対パスの準備ができたら、きれいな静的出力を生成します。"
                ]
            ]
        , namedSection
            "次に読むもの"
            [ LinkGridBlock
                [ slugLinkCard "リファレンスを読む" referenceSlug (Just "対応済みのファミリーと契約ルールを確認します。")
                , slugLinkCard "AI 向けの道筋を見る" aiPathSlug (Just "作業をエージェントに任せる場合の、より狭い導入経路です。")
                , slugLinkCard "テーマシステムを見る" themeSlug (Just "プリセット選択と段階的カスタマイズの考え方を確認します。")
                , slugLinkCard "公開可能性を見る" publishabilitySlug (Just "公開前に Portico が何を検証し、何を出力するかを見ます。")
                , collectionLinkCard "サンプルラボを見る" labHomePath (Just "最小経路が見えたあとに、より広い圧力テスト面を比較します。")
                ]
            ]
        ])

  aiPathPage =
    withSummary
      "サイト作成を AI に委譲するかどうかを決める人のための運用経路。"
      (page
        aiPathSlug
        (CustomKind "AI Path")
        "AI 導入経路"
        [ namedSection
            "委譲"
            [ HeroBlock
                (withActions
                  [ linkCard "エージェント向け Quickstart を開く" githubAgentQuickstartHref (Just "デフォルトの AI 指向実装経路を説明するリポジトリ文書を読む。")
                  , slugLinkCard "公開面を読む" referenceSlug (Just "範囲を広げる前に、対応済みのファミリーと契約ルールを確認します。")
                  , linkCard "repo-first の skill を開く" githubSkillHref (Just "消費側アプリに Portico を組み込むための、ソース優先の導入 skill を見る。")
                  ]
                  (withEyebrow
                    "AI ネイティブな経路"
                    (hero
                      "Portico は、委譲しやすいように設計されている。"
                      "Portico を評価する多くの人は、実装エージェントが正しく扱えるかを見ています。対応済みの経路は意図的に狭く、ひとつの import、セマンティックなサイトプリミティブ、公式テーマ、検証、静的出力に絞られています。")))
            ]
        , namedSection
            "対応済みの運用形"
            [ FeatureGridBlock
                [ feature "ひとつの import 経路" "エージェントは、散らばった低レベルモジュールではなく `Portico` から始めるべきです。"
                , feature "セマンティックなプリミティブ" "執筆面がサイト上の役割を直接名指しすることで、生のレイアウト断片への逸脱を抑えます。"
                , feature "公式テーマ経路" "強いデフォルトと明示的なプリセットで、委譲作業時の見た目の曖昧さを下げます。"
                , feature "公開前検証" "エージェントは、出力を許容する前に、ルート、要約、構造を確認できます。"
                , feature "静的ビルド経路" "レンダリングとファイル出力は、公開ホスティング向けに決定的かつ subpath-safe に保たれます。"
                , feature "repo-first の導入" "現時点で最も安全なのは、明示的な文書と可視な公開面を伴うソース先行の導入です。"
                ]
            ]
        , namedSection
            "エージェントに伝えること"
            [ CodeBlock
                (codeSample
                  "公開静的サイトには Portico を使う。\nPortico から import する。\nセマンティックな site プリミティブに留まる。\nテーマの関心事はコンテンツモデルから分離する。\nofficialTheme か officialThemeWith* を使う。\n公開前に validateSite を実行する。\nemitSite か emitMountedSite で静的出力を生成する。"
                  (Just "text")
                  (Just "実装エージェント向けの最小タスクパケット"))
            , CalloutBlock
                (callout Quiet "プレベータの姿勢" "しばらくは導入経路を repo-first に保ちます。ローカル checkout、明示的な公開面、そして consuming workspace での検証です。")
            ]
        , namedSection
            "運用上の参照"
            [ LinkGridBlock
                [ linkCard "エージェント向け Quickstart" githubAgentQuickstartHref (Just "デフォルトの AI 指向実装経路のリポジトリ文書。")
                , linkCard "portico-user skill" githubSkillHref (Just "Portico を消費側アプリへ配線するための repo-first 導入 skill。")
                , slugLinkCard "公開面" referenceSlug (Just "公式サイト上の対応済みファミリーと契約ルール。")
                , slugLinkCard "公開可能性" publishabilitySlug (Just "契約の検証、メタデータ、静的出力の側面。")
                , linkCard "配布メモ" githubDistributionHref (Just "現在の repo-first 姿勢と、あとで package 化する分配方針。")
                , linkCard "GitHub を開く" githubRepositoryHref (Just "公開リポジトリを現在の真実として使います。")
                ]
            ]
        ])

  referencePage =
    withSummary
      "現在対応済みの Portico 面、契約ルール、文書マップ。"
      (page
        referenceSlug
        (CustomKind "Reference")
        "公開面"
        [ namedSection
            "対応済みのファミリー"
            [ FeatureGridBlock
                [ feature "Portico.Site" "Site, page, section, block, navigation, link, 公開時メタデータの各プリミティブ。"
                , feature "Portico.Build" "`emitSite` や `emitMountedSite` などの静的ファイル出力ヘルパー。"
                , feature "Portico.Render" "`renderSite`、`renderStaticSite`、`renderPage`、`renderStylesheet` などの純粋なレンダリングヘルパー。"
                , feature "Portico.Validate" "`validateSite`、`siteDiagnostics`、`hasErrors` などの公開可能性診断。"
                , feature "Portico.Theme" "テーマトークンと段階的カスタマイズのヘルパー。"
                , feature "Portico.Theme.Official" "公式プリセットと `officialThemeWith*` のカスタマイズ経路。"
                ]
            ]
        , namedSection
            "契約ルール"
            [ FeatureGridBlock
                [ feature "`Portico` から import する" "プレベータの面が落ち着くまでは、統合モジュールを意図された公開入口として扱います。"
                , feature "セマンティックなプリミティブを優先する" "同じパターンが繰り返されるなら、原始的なマークアップを散らすのではなくドメインブロックを追加・改良します。"
                , feature "テーマは分離する" "見た目の選択は、ページモデルではなくテーマ層に置きます。"
                , feature "route ヘルパーを優先する" "内部の相対パスを手で書く代わりに、site と collection のヘルパーを使います。"
                , feature "`validateSite` を走らせる" "リリース前の対応済みワークフローの一部として、公開可能性診断を扱います。"
                ]
            ]
        , namedSection
            "文書マップ"
            [ LinkGridBlock
                [ slugLinkCard "適用範囲を確認する" learnSlug (Just "カテゴリー適合、スコープ、Portico と Asterism の境界。")
                , slugLinkCard "始め方を見る" startSlug (Just "import から出力までの最短の対応済み経路。")
                , slugLinkCard "AI 導入経路" aiPathSlug (Just "委譲実装のための、より狭い repo-first 経路。")
                , slugLinkCard "テーマシステム" themeSlug (Just "プリセット選択と段階的カスタマイズ。")
                , slugLinkCard "公開可能性" publishabilitySlug (Just "検証、メタデータ、静的出力、配布向けファイル。")
                , slugLinkCard "リリース 0.1.0" releaseSlug (Just "今使えるものと、まだ変化中のもの。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "ドキュメント、プロダクト、ポートフォリオ、プロフィール、イベント、出版系の広い証拠面。")
                , linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages 向けの build と base URL の流れ。")
                , linkCard "リリースチェックリスト" githubReleaseChecklistHref (Just "現在の repo-first 公開ゲートとチェックリスト。")
                ]
            ]
        , namedSection
            "まだ動いているもの"
            [ CalloutBlock
                (callout Quiet "プレベータ契約" "正確なブロック語彙、検証器の深さ、最初の stylesheet を越えた asset story、長期的な package 分割は、どれもプレベータ中にまだ動く想定です。")
            ]
        ])

  themePage =
    withSummary
      "公式プリセットと段階的カスタマイズの関係。"
      (page
        themeSlug
        Documentation
        "テーマシステム"
        [ namedSection
            "選び方"
            [ ProseBlock "アクセントカラーを考える前に、まずはサイトの意図と読みの姿勢から始めます。公式システムは、強い公開面をすばやく作るために、十分に意見を持つよう設計されています。"
            , FeatureGridBlock
                [ feature "意図から始める" "色やタイポグラフィを調整する前に、ドキュメント、スタジオ、ローンチ、出版といった姿勢を選びます。"
                , feature "段階的にカスタマイズする" "accent、palette、typography、spacing、surface、radius、shadow は、公式システムの上に重ねます。置き換えません。"
                , feature "DSL はセマンティックに保つ" "テーマの詳細はテーマ層に属し、ページモデルに混ぜません。"
                ]
            ]
        , namedSection
            "公式プリセット"
            [ FeatureGridBlock
                [ feature "SignalPaper" "公式ドキュメントとプロジェクト面に向いた、落ち着いた標準。"
                , feature "CopperLedger" "より引き締まった、やや暖色のスタジオ／ポートフォリオ向けの声。"
                , feature "NightCircuit" "広めで暗めの、技術系ローンチやイベント向けの声。"
                , feature "BlueLedger" "より狭く、出版物やノートブック向けの声。"
                ]
            ]
        , namedSection
            "カスタマイズの階段"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nlaunchTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#0f766e\"\n      , spacing = Just\n          { pageInset: \"3.2rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"5.6rem\"\n          , sectionGap: \"3.2rem\"\n          , stackGap: \"1.3rem\"\n          , cardPadding: \"1.4rem\"\n          , heroPadding: \"2.35rem\"\n          }\n      })"
                  (Just "purescript")
                  (Just "公式テーマのカスタマイズに向けた、ひとつのコードファースト入口"))
            , CalloutBlock
                (callout Quiet "任意の裏付け" "サイトカテゴリが明確になってから、プリセットカタログを使います。最初の決定点ではなく、補助的な証拠です。")
            , LinkGridBlock
                [ collectionLinkCard "プリセットカタログを見る" presetCatalogPath (Just "プリセットが生成サンプル面にどう対応するかを確認します。")
                , collectionLinkCard "サンプルラボを比較する" labHomePath (Just "複数のサイトカテゴリーをまたいで公式テーマシステムを検証します。")
                , slugLinkCard "始め方へ戻る" startSlug (Just "テーマを選ぶ間も、対応済みの執筆経路を見失わないようにします。")
                , slugLinkCard "リファレンスへ戻る" referenceSlug (Just "カスタマイズしながら、対応済みの面を再確認します。")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "公開面のための検証、ビルド出力、デプロイ向けメタデータ。"
      (page
        publishabilitySlug
        Documentation
        "公開可能性"
        [ namedSection
            "Portico が確認すること"
            [ FeatureGridBlock
                [ feature "まず検証する" "公開前に、index の欠落、重複パス、壊れた内部ルート、弱い要約、誤配置された hero を確認します。"
                , feature "モデルからメタデータを作る" "canonical、OG、Twitter の各タグは、生の head マークアップではなく site と page の値から導きます。"
                , feature "多言語 bundle" "ローカライズされたサイト群でも、`lang`、言語切替ルート、`hreflang` alternate を、本物の静的ページとして出力できます。クライアント側アプリにする必要はありません。"
                , feature "静的出力" "ネストしたルート、共有 CSS アセット、mounted collections の下でも subpath-safe なファイルを出力します。"
                , feature "Pages 向けファイル" "GitHub Pages 風の出力には、`404.html`、`robots.txt`、`sitemap.xml` を含めても、セマンティックな DSL を汚しません。"
                ]
            ]
        , namedSection
            "ビルド順序"
            [ TimelineBlock
                [ timelineEntry "Render" "ページモデルがまだ動いている間の、素早い確認やインラインプレビューに `renderSite` を使います。" Nothing
                , timelineEntry "Validate" "サイト定義をリリース可能とみなす前のゲートとして `validateSite` を使います。" Nothing
                , timelineEntry "Localize" "公開サイトに言語切替が必要なら、ランタイム中心の状態ではなく、locale variant を静的 bundle としてまとめます。" Nothing
                , timelineEntry "Emit" "静的ホスティング出力の準備ができたら `emitSite`、`emitMountedSite`、`emitLocalizedSite` を使います。" Nothing
                , timelineEntry "Publish" "本当の公開アーティファクトとして振る舞わせる段階で、base URL とデプロイ向けファイルを追加します。" Nothing
                ]
            , CodeBlock
                (codeSample
                  "import Portico\n\nreport = validateLocalizedSite localizedDefinition\nsiteHasErrors = hasLocalizedErrors localizedDefinition\n\nmain =\n  emitLocalizedSite \"site/dist\" officialTheme localizedDefinition"
                  (Just "purescript")
                  (Just "ローカライズされた bundle を検証してから出力する"))
            ]
        , namedSection
            "よくある質問"
            [ FaqBlock
                [ faqEntry "レンダリングに base URL は必要ですか?" "いいえ。base URL が必要になるのは canonical と social metadata を出したいときで、ローカルプレビュー中ではありません。"
                , faqEntry "Portico で静的サイトを localize できますか?" "できます。対応済みの道筋は static-first です。複数 locale を本物のページとして出力し、言語切替はリンクベースで扱い、build layer が `lang` と alternate metadata を担当します。"
                , faqEntry "相対リンクは手書きすべきですか?" "ネストした出力でも整合が保たれるよう、route ヘルパーや mounted collection ヘルパーを優先してください。"
                , faqEntry "リリース向けの repo チェックは何ですか?" "`npm run verify` を使います。テストに加えて、単体の sample-lab、official-site、GitHub Pages 風 build 出力をまとめて確認します。"
                , faqEntry "Portico は静的 CMS を目指していますか?" "いいえ。対象は、強い情報アーキテクチャを持つ、作成済みの静的面です。コンテンツ管理ツールではありません。"
                ]
            ]
        , namedSection
            "デプロイ向け文書"
            [ LinkGridBlock
                [ slugLinkCard "リファレンスを読む" referenceSlug (Just "対応済みのファミリーと契約ルールへ戻ります。")
                , slugLinkCard "AI 向けの道筋を読む" aiPathSlug (Just "委譲された執筆経路を公開可能性の契約に揃えます。")
                , linkCard "デプロイガイドを読む" githubDeploymentHref (Just "GitHub Pages 向けの build と base URL の流れを確認します。")
                , linkCard "リリースチェックリストを読む" githubReleaseChecklistHref (Just "repo-first の公開ゲートとチェックリストを見ます。")
                ]
            ]
        ])

  releasePage =
    withSummary
      "Portico の最初の動く切り出し。"
      (page
        releaseSlug
        ReleaseNotes
        "リリース 0.1.0"
        [ namedSection
            "今すぐ使えるもの"
            [ FeatureGridBlock
                [ feature "型付きサイトモデル" "公開静的面のための site, page, section, navigation, route, block の語彙は、すでに揃っています。"
                , feature "公式テーマシステム" "公式プリセット経路、段階的カスタマイズ、プリセットカタログはすでに利用できます。"
                , feature "公開可能性とビルド" "検証、canonical/social metadata、静的出力、多言語 bundle、GitHub Pages 風出力は、repo-first の切り出しに含まれています。"
                , feature "mounted な証拠面" "公式サイトと広いサンプルラボが、公開オンボーディング面として並んで出ています。"
                ]
            ]
        , namedSection
            "現在の姿勢"
            [ CalloutBlock
                (callout Strong "状態" "Portico は公開プレベータです。公式サイト、リポジトリ文書、サンプルラボ、検証経路、GitHub Pages ビルドは live ですが、package 配布と最終的な契約詳細はまだ動いています。")
            ]
        , namedSection
            "まだ動いているもの"
            [ FeatureGridBlock
                [ feature "ブロック語彙" "正確なセマンティックブロック集合は、実際の公開サイト形状に対して引き続き圧力テストされます。"
                , feature "検証器の深さ" "診断範囲は、最初の公開可能性チェックを越えて広がっていきます。"
                , feature "アセット story" "最初の shared stylesheet と mounted sample assets を越えた先は、まだ意図的に開かれています。"
                , feature "package 分割" "将来的な registry packaging と package metadata は、まだ意図的に後ろ倒しです。"
                ]
            ]
        , namedSection
            "次の動き"
            [ LinkGridBlock
                [ slugLinkCard "適用範囲を確認する" learnSlug (Just "カテゴリーとスコープの整理に戻ります。")
                , slugLinkCard "対応済みの道筋から始める" startSlug (Just "リリース姿勢から具体的な執筆経路へ進みます。")
                , collectionLinkCard "サンプルラボを見る" labHomePath (Just "圧力テスト面を使って、モデルの改善点を探します。")
                , linkCard "GitHub を開く" githubRepositoryHref (Just "コード、課題、文書、現在のプレベータ姿勢を公開リポジトリで追います。")
                ]
            ]
        ])
