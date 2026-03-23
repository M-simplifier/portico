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
          "PureScript で公開サイトを作るための静的サイトライブラリ。"
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
    "import Portico\n\nsiteDefinition =\n  site \"Signal Manual\"\n    [ withSummary\n        \"落ち着いたドキュメントの入口。\"\n        (page \"index\" Landing \"Signal Manual\"\n          [ namedSection \"概要\"\n              [ HeroBlock\n                  (withEyebrow\n                    \"公開サイト\"\n                    (hero\n                      \"公開サイトの入口を作る。\"\n                      \"情報の構造をそのまま書き、静的出力まで素直につなげます。\"))\n              ]\n          ])\n    ]\n\nmain = do\n  let report = validateSite siteDefinition\n  emitSite \"site/dist\" officialTheme siteDefinition"

  themeCode =
    "import Portico\n\nsiteTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#2563eb\"\n      , spacing = Just\n          { pageInset: \"3.6rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"6rem\"\n          , sectionGap: \"4.2rem\"\n          , stackGap: \"1.35rem\"\n          , cardPadding: \"1.45rem\"\n          , heroPadding: \"2.7rem\"\n          }\n      })"

  localizedCode =
    "import Portico\n\nlocalizedDefinition =\n  localizedSite\n    englishLocale\n    [ localizedVariant englishLocale \"英語\" \"\" englishSite\n    , localizedVariant japaneseLocale \"日本語\" \"ja\" japaneseSite\n    ]\n\nmain = do\n  let report = validateLocalizedSite localizedDefinition\n  emitLocalizedSite \"site/dist\" officialTheme localizedDefinition"

  aiChecklistCode =
    "Portico は公開向けの静的サイトに使う。\n入口は Portico に揃える。\nsite、page、section、定番のブロックを優先する。\n相対リンクは手で書かず、ルートヘルパーに任せる。\nテーマの判断は内容構造と分ける。\n公開前に validateSite か validateLocalizedSite を通す。\n出力には emitSite、emitMountedSite、emitLocalizedSite を使う。"

  homePage =
    withSummary
      "情報の構造、公式テーマ、検証、静的出力をひとつに保つ Portico の公式サイト。"
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "概要"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "ここから始める" startSlug (Just "ひとつの import から、動くサイトと公開用の出力まで進みます。")
                  , collectionLinkCard "サンプルラボを見る" labHomePath (Just "ドキュメント、製品紹介、ポートフォリオ、イベント、読み物の作例を見比べます。")
                  , linkCard "GitHub で見る" githubRepositoryHref (Just "リポジトリ、ドキュメント、現在の公開状態を確認します。")
                  ]
                  (withEyebrow
                    "公開サイト"
                    (hero
                      "公開サイトの入口を、情報の構造から作る。"
                      "Portico は、ドキュメント、公式サイト、リリースページ、ポートフォリオ、読み物のための PureScript ライブラリです。情報の構造をそのままサイトとして記述し、公式テーマから始めて、公開前の検証と静的出力までひと続きに扱えます。")))
            , MetricsBlock
                [ metric "`Portico`" "ひとつの入口" (Just "サイト定義、テーマ、描画、検証、出力までを、`Portico` ひとつで始められます。")
                , metric "6" "作例" (Just "ドキュメント、製品紹介、ポートフォリオ、プロフィール、イベント、読み物の作例を用意しています。")
                , metric "2言語" "公式サイトの言語" (Just "英語をルート、日本語を /ja/ に出力します。")
                , metric "`npm run verify`" "検証コマンド" (Just "テスト、公式サイト、GitHub Pages 向け出力までまとめて確認します。")
                ]
            , CodeBlock
                (codeSample
                  gettingStartedCode
                  (Just "purescript")
                  (Just "サイトモデルから静的出力へ"))
            ]
        , namedSection
            "Portico が目指すもの"
            [ ProseBlock "多くのサイトツールは、テンプレートや Markdown パイプライン、あるいはレイアウトの自由度から始まります。Portico はその一段手前、公開サイトの情報設計から始めます。"
            , FeatureGridBlock
                [ feature "意味のあるサイトモデル" "サイト、ページ、セクション、ナビゲーション、ブロックを値として保ち、場当たり的なマークアップに埋めません。"
                , feature "公式テーマシステム" "まずサイトの雰囲気を決め、そのあとで配色、文字組み、余白、面の表情を段階的に整えます。"
                , feature "公開前チェック" "壊れたリンク、弱い要約、重複したセクション、メタデータ不足を公開前に見つけます。"
                , feature "静的ファーストの多言語対応" "言語ごとに実ページを出力し、lang 属性や代替ページ向けメタデータもビルド側で扱います。"
                ]
            , CalloutBlock
                (callout Strong "Asterism を軽くしたものではない" "認証、長く生きる状態、重い相互作用、アプリシェル寄りの振る舞いが必要なら、設計の中心はすでに Portico の外にあります。")
            ]
        , namedSection
            "向いているサイト"
            [ FeatureGridBlock
                [ feature "公式プロジェクトサイト" "何のプロダクトで、どこから読み始めればよいかがすぐ伝わる入口。"
                , feature "ドキュメントとガイド" "概念説明、導入、階層化したリファレンス、リリース情報を落ち着いて読ませるサイト。"
                , feature "リリースと更新記録" "静的公開に向いた、更新記録や発表のためのページ。"
                , feature "ポートフォリオと読み物" "構造と余白が大事で、相互作用の密度は主役でないサイト。"
                ]
            , LinkGridBlock
                [ slugLinkCard "Portico が向くサイト" whySlug (Just "スコープと設計の中心をまとめて確認します。")
                , slugLinkCard "AI で進める" aiPathSlug (Just "実装エージェントを迷いの少ない導線に乗せます。")
                , slugLinkCard "リファレンス" referenceSlug (Just "現在公開しているモジュール群と運用ルールを確認します。")
                , slugLinkCard "ここから始める" startSlug (Just "最小の導入経路へ進みます。")
                ]
            ]
        , namedSection
            "作って確かめる"
            [ CalloutBlock
                (callout Accent "公式サイトも Portico 自身で出している" "英語版、日本語版、サンプルラボまで、Portico 自身で出力しています。実際の公開サイトを自前で運用し、ライブラリの弱点を外に逃がさないためです。")
            , LinkGridBlock
                [ collectionLinkCard "サンプルラボを見る" labHomePath (Just "複数カテゴリの公開サイトを横断して比較します。")
                , collectionLinkCard "プリセットカタログを見る" presetCatalogPath (Just "細かな調整の前に、サイトの意図からテーマを選びます。")
                , slugLinkCard "テーマシステム" themeSlug (Just "プリセットと段階的な調整の関係を確認します。")
                , slugLinkCard "公開" publishabilitySlug (Just "検証、メタデータ、多言語出力、公開向けファイルを確認します。")
                ]
            ]
        , namedSection
            "現在地"
            [ CalloutBlock
                (callout Quiet "プレベータ公開中" "Portico はいま十分に評価できますが、公開 API や配布方針はまだ固めている途中です。基準になるのは、リポジトリ、公式サイト、`npm run verify` です。")
            , LinkGridBlock
                [ slugLinkCard "リリース 0.1.0" releaseSlug (Just "いま入っているものと、まだ調整中のものを整理して見ます。")
                , linkCard "GitHub で見る" githubRepositoryHref (Just "コード、ドキュメント、Issue、現在の公開方針を確認します。")
                , linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages 向けの base URL と公開フローを確認します。")
                , linkCard "コントリビュート方針" (githubRepositoryHref <> "/blob/main/CONTRIBUTING.md") (Just "プレベータ時点の受け付け方と応答方針を確認します。")
                ]
            ]
        ])

  whyPage =
    withSummary
      "Portico が向くサイトと、なぜスコープを狭く保っているのか。"
      (page
        whySlug
        (CustomKind "位置づけ")
        "Portico が向くサイト"
        [ namedSection
            "設計の中心"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "ここから始める" startSlug (Just "最小の導入経路から始めます。")
                  , slugLinkCard "公開" publishabilitySlug (Just "公開前の検証とメタデータの扱いを確認します。")
                  , collectionLinkCard "サンプルラボを見る" labHomePath (Just "複数カテゴリで Portico を検証します。")
                  ]
                  (withEyebrow
                    "対象範囲"
                    (hero
                      "静的サイトのライブラリは、公開面の構造を理解しているべきです。"
                      "Portico は、何のサイトなのか、どこから読み始めればよいのか、どこに根拠があるのかが大事な公開サイトのためにあります。アプリの外枠を作るためのものではありません。")))
            , FeatureGridBlock
                [ feature "公式サイト" "何のプロダクトで、どう始めればよく、詳しい説明がどこにあるかを整理して見せるサイト。"
                , feature "ドキュメントと学習向けサイト" "理解のために読む人へ向けた概念ページ、導入、階層化したリファレンス。"
                , feature "リリース情報" "静的公開に強い、リリース、更新記録、告知ページ。"
                , feature "読み物とケーススタディ" "情報の順序と余白が大事な、ポートフォリオや読み物のページ。"
                ]
            , CalloutBlock
                (callout Strong "意図的に外している領域" "ダッシュボード、エディタ、認証付きアプリ、相互作用の重いブラウザソフトは別のランタイムモデルを必要とします。そこは Asterism の仕事です。")
            ]
        , namedSection
            "プロダクトの考え方"
            [ ProseBlock "Portico は、あらゆる Web サイトのための道具ではありません。狙いは、見た目に意図があり、AI にも人にも扱いやすく、公開まで迷いにくい静的な公開サイトに絞って強くすることです。"
            , FeatureGridBlock
                [ feature "最初に何のプロダクトかが伝わる" "良い公式サイトは、最初の画面で何のプロダクトかが分かります。Portico もそこを中心に据えます。"
                , feature "次にどこを読めばよいかが見える" "始め方、テーマ、公開、リファレンスがひとつの流れとして読めるべきです。"
                , feature "証拠は近くに置く" "サンプル、リリース、リポジトリは必要ですが、入口を押しのける主役ではありません。"
                , feature "静的出力まで設計に含める" "ルート、メタデータ、多言語出力、公開向けファイルは、おまけではなくサイトそのものの一部です。"
                ]
            ]
        , namedSection
            "合いそうなら"
            [ LinkGridBlock
                [ slugLinkCard "ここから始める" startSlug (Just "最小のサイトをつくり、導入の流れを体で確認します。")
                , slugLinkCard "テーマシステム" themeSlug (Just "サイトの表情を決め、その後で細部を整えます。")
                , slugLinkCard "公開" publishabilitySlug (Just "検証と公開向け出力を実装の流れに戻します。")
                , slugLinkCard "リファレンス" referenceSlug (Just "公開モジュール群と利用ルールを確認します。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリのサイトの形を見比べます。")
                ]
            ]
        ])

  startPage =
    withSummary
      "ひとつの import から、公開できる静的サイトまで進む最短経路。"
      (page
        startSlug
        (CustomKind "導入")
        "始める"
        [ namedSection
            "基本の流れ"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "リファレンス" referenceSlug (Just "内部へ降りる前に、公開 API の全体像を確認します。")
                  , slugLinkCard "テーマシステム" themeSlug (Just "見た目を細かく調整する前に方向を選びます。")
                  , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで Portico を見比べます。")
                  ]
                  (withEyebrow
                    "作り方"
                    (hero
                      "ひとつの import から、公開サイトまでつなぐ。"
                      "Portico から始め、情報の構造としてサイトを組み立て、公式テーマを選び、検証してから静的ファイルを出力します。狙いは手順を増やすことではなく、迷いを減らすことです。")))
            , TimelineBlock
                [ timelineEntry "`Portico` から import する" "サイト定義、テーマ、描画、検証、出力を、ひとつの分かりやすい入口に保ちます。" Nothing
                , timelineEntry "サイトを構造から組み立てる" "ページ、セクション、ナビゲーション、ルートを、レイアウト断片ではなく構造として記述します。" Nothing
                , timelineEntry "公式テーマから入る" "配色や余白を手で詰める前に、公式テーマかプリセットから入ります。" Nothing
                , timelineEntry "検証して出力する" "公開サイトとして筋が通ったら validateSite を通し、静的出力を生成します。" Nothing
                ]
            , CodeBlock
                (codeSample
                  gettingStartedCode
                  (Just "purescript")
                  (Just "最小の Portico サイト"))
            ]
        , namedSection
            "最初に触る API"
            [ FeatureGridBlock
                [ feature "`Portico` から始める" "個別モジュールへ降りる前に、まずは公開ルートの `Portico` を使います。"
                , feature "`site` / `page` / `namedSection`" "公開情報の構造をレイアウト用マークアップに埋めず、値として持ちます。"
                , feature "`officialThemeWith`" "見た目の調整をテーマトークンの層に閉じ込めます。"
                , feature "`validateSite` と `emitSite`" "診断と静的出力を普段の作業ループに含めます。"
                ]
            ]
        , namedSection
            "次に読む"
            [ LinkGridBlock
                [ slugLinkCard "リファレンス" referenceSlug (Just "公開モジュール群と利用ルールを確認します。")
                , slugLinkCard "公開" publishabilitySlug (Just "公開前に何を検証し、何を出力するかを確認します。")
                , slugLinkCard "AI で進める" aiPathSlug (Just "委譲時も同じ導線を守ります。")
                , slugLinkCard "テーマシステム" themeSlug (Just "プリセットと段階的な調整を確認します。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで Portico のサイトの形を比べます。")
                ]
            ]
        ])

  aiPage =
    withSummary
      "実装エージェントが迷わず進めるための AI 向けガイド。"
      (page
        aiPathSlug
        (CustomKind "AI")
        "AI で進める"
        [ namedSection
            "委譲するなら、境界も一緒に渡す"
            [ HeroBlock
                (withActions
                  [ linkCard "エージェント導入ガイド" githubAgentQuickstartHref (Just "Portico を使うときの最短導線です。")
                  , linkCard "portico-user スキル" githubSkillHref (Just "利用側のアプリに Portico を組み込むためのスキルです。")
                  , slugLinkCard "公開" publishabilitySlug (Just "公開前チェックも委譲内容に含めます。")
                  ]
                  (withEyebrow
                    "AI 向け導線"
                    (hero
                      "実装エージェントには、迷わない導線だけを渡す。"
                      "Portico は、ひとつの import から、意味のあるプリミティブ、公式テーマ、検証、静的出力までを途切れず扱えるよう、意図的に絞って設計されています。")))
            , FeatureGridBlock
                [ feature "入口はひとつ" "散らばった低レベルモジュールではなく、Portico から始めます。"
                , feature "意味のあるプリミティブを優先" "site、page、section、ルートヘルパー、定番のブロックを先に使います。"
                , feature "相対リンクは手書きしない" "出力ツリーやマウント位置が変わっても、ルートヘルパーに相対リンクを任せます。"
                , feature "公開前に検証する" "validateSite や validateLocalizedSite を関門にします。"
                ]
            , CodeBlock
                (codeSample
                  aiChecklistCode
                  Nothing
                  (Just "委譲前チェックリスト"))
            ]
        , namedSection
            "守るべき不変条件"
            [ FeatureGridBlock
                [ feature "最初にサイトの種類を決める" "公式サイト、ドキュメント、リリースページ、読み物のどれかを曖昧にしません。"
                , feature "繰り返す形はプリミティブへ戻す" "同じ形が何度も出るなら、Portico のブロックを育てます。"
                , feature "テーマは内容モデルから分ける" "見た目の判断をサイトモデルに漏らしません。"
                , feature "静的ファーストを崩さない" "言語別ページ、メタデータ、ルート構造は、ランタイムより先に実ページとして出力します。"
                ]
            ]
        , namedSection
            "関連リンク"
            [ LinkGridBlock
                [ slugLinkCard "始める" startSlug (Just "最小の導線を先に踏みます。")
                , slugLinkCard "リファレンス" referenceSlug (Just "委譲中も公開面の前提を見失わないためです。")
                , slugLinkCard "公開" publishabilitySlug (Just "検証とデプロイ用メタデータを委譲内容に入れます。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリでサイトの形を比較します。")
                ]
            ]
        ])

  referencePage =
    withSummary
      "現在の公開 API、利用ルール、関連ドキュメント。"
      (page
        referenceSlug
        Documentation
        "リファレンス"
        [ namedSection
            "現在の公開 API"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "始める" startSlug (Just "最小の導線を先に確認します。")
                  , linkCard "GitHub" githubRepositoryHref (Just "現在の公開 API の基準になっているリポジトリです。")
                  , linkCard "アーキテクチャ" githubArchitectureHref (Just "意味の層、テーマ、ビルド、検証の分け方を確認します。")
                  ]
                  (withEyebrow
                    "公開 API"
                    (hero
                      "いま使える公開モジュールは、ここです。"
                      "Portico はまだプレベータですが、いま使うべき公開 API は、ひとつの import と静的サイト向けの流れを中心に整理されています。")))
            , FeatureGridBlock
                [ feature "Portico.Site" "サイト、ページ、セクション、ブロック、ナビゲーション、リンク、言語、公開時メタデータのプリミティブ。"
                , feature "Portico.Build" "emitSite、emitMountedSite、emitLocalizedSite など、静的ファイル出力のヘルパー。"
                , feature "Portico.Render" "renderSite、renderStaticSite、renderPage、renderStylesheet など、純粋な描画ヘルパー。"
                , feature "Portico.Validate" "validateSite、validateLocalizedSite など、公開前診断のための検証。"
                , feature "Portico.Theme" "テーマトークンと段階的な調整のためのヘルパー。"
                , feature "Portico.Theme.Official" "公式プリセットと officialThemeWith による調整経路。"
                ]
            ]
        , namedSection
            "利用ルール"
            [ FeatureGridBlock
                [ feature "Portico から import する" "プレベータのあいだは、公開の入口である Portico を正式な入口として扱います。"
                , feature "意味のあるブロックを優先する" "公開サイトで同じ構造が何度も出るなら、レイアウト断片ではなく意味のあるブロックに戻します。"
                , feature "テーマを分離する" "見た目の判断はテーマ層に置き、内容モデルに混ぜません。"
                , feature "公開前に検証する" "診断を通常の作業フローの一部として扱います。"
                ]
            ]
        , namedSection
            "関連ドキュメント"
            [ LinkGridBlock
                [ linkCard "ビジョン" githubVisionHref (Just "Portico がなぜ存在するか、どこまでを対象にするか。")
                , linkCard "アーキテクチャ" githubArchitectureHref (Just "意味の層、テーマ、ビルド、検証、optional islands をどう分けているか。")
                , linkCard "エージェント導入ガイド" githubAgentQuickstartHref (Just "実装エージェント向けの導線です。")
                , linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages と base URL の公開フロー。")
                , linkCard "配布方針" githubDistributionHref (Just "いまリポジトリ中心で公開している理由と、パッケージ配布を後ろに置いている理由。")
                , linkCard "リリースチェックリスト" githubReleaseChecklistHref (Just "プレベータのリリース基準と公開チェックリスト。")
                ]
            ]
        ])

  themePage =
    withSummary
      "公式プリセットと段階的な調整の組み立て方。"
      (page
        themeSlug
        Documentation
        "テーマシステム"
        [ namedSection
            "表情を選び、そのあとで整える"
            [ HeroBlock
                (withActions
                  [ collectionLinkCard "プリセットカタログ" presetCatalogPath (Just "細かな調整の前に、サイトの意図からテーマを選びます。")
                  , collectionLinkCard "サンプルラボ" labHomePath (Just "実際のサンプル上で公式テーマを見比べます。")
                  , slugLinkCard "始める" startSlug (Just "まずひとつ作ってから調整の幅を広げます。")
                  ]
                  (withEyebrow
                    "テーマ"
                    (hero
                      "テーマは、単なる変数ではなく、サイトの表情から選ぶ。"
                      "Portico の公式テーマシステムは、方向のあるプリセットを先に置き、そのあとで配色、文字組み、余白、面の表情、角丸、影を段階的に調整します。")))
            , FeatureGridBlock
                [ feature "SignalPaper" "ドキュメントや公式サイトに向く、静かな標準。"
                , feature "CopperLedger" "スタジオ、ポートフォリオ、ケーススタディに向く、少し暖かく締まったトーン。"
                , feature "NightCircuit" "公開告知、技術発表、イベントに向く、広がりのあるダークトーン。"
                , feature "BlueLedger" "ノート、エッセイ、読み物に向く、細めのエディトリアルトーン。"
                ]
            , CodeBlock
                (codeSample
                  themeCode
                  (Just "purescript")
                  (Just "公式テーマの段階的な調整"))
            ]
        , namedSection
            "無理なく変えられるもの"
            [ FeatureGridBlock
                [ feature "アクセント / パレット" "ブランドカラーだけを寄せることも、配色全体を差し替えることもできます。"
                , feature "タイポグラフィ" "描画用のマークアップを崩さず、見出し、本文、等幅フォントを切り替えられます。"
                , feature "余白" "密度とページ全体のリズムをテーマトークンの層で調整できます。"
                , feature "面と外枠" "枠の幅、pill の形、ヘッダー、ヒーローの見え方を内容の値から分けて扱えます。"
                ]
            , CalloutBlock
                (callout Quiet "公式サイトも同じ仕組みで動いている" "Portico の公式サイトも、ライブラリの外側で別 CSS を書くのではなく、公式テーマシステムの上に載せています。")
            ]
        , namedSection
            "実例で見る"
            [ LinkGridBlock
                [ collectionLinkCard "プリセットカタログ" presetCatalogPath (Just "プリセットと調整方法をひとつの一覧で比較します。")
                , collectionLinkCard "Northline Docs" docsSamplePath (Just "落ち着いたドキュメント向けのトーンを確認します。")
                , collectionLinkCard "Northstar Cloud" productSamplePath (Just "公式テーマを製品紹介に寄せた例です。")
                , collectionLinkCard "Mina Arai" profileSamplePath (Just "プロフィールとケーススタディへの適用例です。")
                , collectionLinkCard "Signal Summit" summitSamplePath (Just "イベント向けのダークトーンを確認します。")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "検証、メタデータ、多言語出力、公開向け生成物まで含めた公開品質。"
      (page
        publishabilitySlug
        Documentation
        "公開"
        [ namedSection
            "ただの生成物ではなく、サイトとして公開する"
            [ HeroBlock
                (withActions
                  [ linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages 向けの公開導線です。")
                  , slugLinkCard "リリース 0.1.0" releaseSlug (Just "いま入っているものと、まだ調整中の部分を確認します。")
                  , slugLinkCard "AI で進める" aiPathSlug (Just "公開前チェックを委譲の流れに入れます。")
                  ]
                  (withEyebrow
                    "公開品質"
                    (hero
                      "公開品質を、実装の外に追い出さない。"
                      "ルート、要約、メタデータ、言語別ページ、静的ホスト向けの出力はサイトそのものの一部です。Portico はそれらを後工程に回さず、同じ制作の流れの中で扱います。")))
            , FeatureGridBlock
                [ feature "構造とルートの診断" "index ページの不足、パスの重複、section id の重複、内部リンク切れを見つけます。"
                , feature "内容の診断" "要約が弱い、ラベルが空、ヒーローの置き方が不自然、といった公開面の弱さを拾います。"
                , feature "メタデータと言語別出力" "canonical URL、social metadata、lang、hreflang をサイトモデルから導きます。"
                , feature "公開向けファイル" "共有 CSS、404.html、robots.txt、sitemap.xml、言語別の静的ルートを出力します。"
                ]
            , TimelineBlock
                [ timelineEntry "サイトを定義する" "公開構造、メタデータ、言語別ページをサイト定義に持たせます。" Nothing
                , timelineEntry "検証する" "validateSite や validateLocalizedSite を公開前の関門にします。" Nothing
                , timelineEntry "描画して出力する" "整った出力パス、共有 CSS、相対リンク、静的アセットを生成します。" Nothing
                , timelineEntry "デプロイする" "base URL を与え、Pages 向けの出力を作って静的ホスティングへ載せます。" Nothing
                ]
            ]
        , namedSection
            "多言語の静的出力"
            [ CodeBlock
                (codeSample
                  localizedCode
                  (Just "purescript")
                  (Just "多言語の静的公開"))
            , FaqBlock
                [ faqEntry "描画時に base URL は必須ですか?" "必須ではありません。base URL が必要になるのは canonical URL や social URL、sitemap.xml のような公開向け出力を出したいときです。"
                , faqEntry "Portico で多言語サイトを作れますか?" "作れます。想定しているのは、言語ごとに実ページを出力する静的ファーストなやり方です。言語切替はリンクベースに保ちます。"
                , faqEntry "Portico は静的 CMS を目指していますか?" "いいえ。対象は、情報設計をしっかり持った静的サイトであって、コンテンツ管理システムそのものではありません。"
                , faqEntry "公開品質は HTML だけの話ですか?" "違います。CSS アセット、canonical / social metadata、言語別 alternate、静的ホスト向けの補助ファイルまで含みます。"
                ]
            ]
        , namedSection
            "次に読む"
            [ LinkGridBlock
                [ slugLinkCard "リファレンス" referenceSlug (Just "公開導線を支えるモジュールを確認します。")
                , slugLinkCard "AI で進める" aiPathSlug (Just "検証と公開まわりの心配事を委譲パケットに含めます。")
                , linkCard "デプロイガイド" githubDeploymentHref (Just "GitHub Pages 向けの公開フローです。")
                , collectionLinkCard "サンプルラボ" labHomePath (Just "複数カテゴリで出力の筋を見比べます。")
                ]
            ]
        ])

  releasePage =
    withSummary
      "Portico の最初の実用的な一式。"
      (page
        releaseSlug
        ReleaseNotes
        "リリース 0.1.0"
        [ namedSection
            "現在のリリース"
            [ HeroBlock
                (withActions
                  [ linkCard "GitHub" githubRepositoryHref (Just "リポジトリ、CHANGELOG、Issue を確認します。")
                  , collectionLinkCard "サンプルラボ" labHomePath (Just "ライブラリの実地検証に使っている公開サイト群を見ます。")
                  , linkCard "配布方針" githubDistributionHref (Just "いまリポジトリ中心で公開している理由と、パッケージ配布を後ろに置く理由です。")
                  ]
                  (withEyebrow
                    "現在地"
                    (hero
                      "Portico はプレベータ公開中です。"
                      "サイトモデル、公式テーマシステム、検証レイヤー、多言語出力、GitHub Pages 向けのビルド経路は、すでに実際に動いています。一方で、パッケージ配布と最終的な公開 API の約束はまだ調整中です。")))
            , FeatureGridBlock
                [ feature "意味のあるサイト DSL" "公開サイト向けの site、page、section、navigation、metadata と、検証済みの block primitive。"
                , feature "公式テーマシステム" "方向のあるプリセットと段階的な調整による見た目の仕組み。"
                , feature "公開品質とビルド" "検証、canonical / social metadata、多言語出力、Pages 向け出力がリポジトリに入っています。"
                , feature "自前で使う公開面" "公式サイトとサンプルラボの両方を、Portico 自身で出力しています。"
                ]
            , CalloutBlock
                (callout Strong "このリリースが意味すること" "Portico はローカルの checkout から十分に評価できる段階です。ただし、パッケージレジストリ経由の配布のような安定性や提供姿勢まではまだ約束していません。")
            ]
        , namedSection
            "何が入ったか"
            [ FeatureGridBlock
                [ feature "静的サイトの基礎" "相対リンク、共有 CSS、アセット、canonical metadata、静的ファイル出力。"
                , feature "多言語の公開" "英語をルート、日本語を /ja/ に、ひとつの多言語サイト定義から出力します。"
                , feature "validator の基礎" "パス衝突、リンク切れ、弱い要約、ヒーローの置き方など、公開前に確認したい点を診断します。"
                , feature "検証用ギャラリー" "6 個のサンプルサイトとプリセットカタログで、モデルの弱点をあぶり出します。"
                ]
            ]
        , namedSection
            "次に強くするもの"
            [ TimelineBlock
                [ timelineEntry "validator を強くする" "最初の公開品質チェックを超えて、リリース判断をもっと支えられる診断へ広げます。" Nothing
                , timelineEntry "アセットの扱いを広げる" "最初の共有 stylesheet だけでなく、公開時のアセットモデルを育てます。" Nothing
                , timelineEntry "公式テーマを強くする" "Portico の出力がもっと意図のある見た目になるよう、公式の見た目を強くします。" Nothing
                , timelineEntry "サンプルラボでもっと検証する" "サイト語彙の弱点が見える作例を増やし、公開面を磨きます。" Nothing
                ]
            , LinkGridBlock
                [ linkCard "リリースチェックリスト" githubReleaseChecklistHref (Just "プレベータのリリース基準と公開チェックリストです。")
                , linkCard "配布方針" githubDistributionHref (Just "リポジトリ中心の現在地と、パッケージ配布の今後を確認します。")
                , slugLinkCard "公開" publishabilitySlug (Just "検証とデプロイ向け出力の側面を確認します。")
                , slugLinkCard "テーマシステム" themeSlug (Just "今後もっと強くしたい見た目の層です。")
                ]
            ]
        ])
