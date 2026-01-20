
**これはQGroundControlのカスタム版です。**

**以下は公式の原文であり、カスタマイズ内容に関するREADMEはその下になります。**


<p align="center">
  <img src="https://raw.githubusercontent.com/Dronecode/UX-Design/35d8148a8a0559cd4bcf50bfa2c94614983cce91/QGC/Branding/Deliverables/QGC_RGB_Logo_Horizontal_Positive_PREFERRED/QGC_RGB_Logo_Horizontal_Positive_PREFERRED.svg" alt="QGroundControl Logo" width="500">
</p>

<p align="center">
  <a href="https://github.com/mavlink/QGroundControl/releases">
    <img src="https://img.shields.io/github/release/mavlink/QGroundControl.svg" alt="Latest Release">
  </a>
</p>

*QGroundControl* (QGC) is a highly intuitive and powerful Ground Control Station (GCS) designed for UAVs. Whether you're a first-time pilot or an experienced professional, QGC provides a seamless user experience for flight control and mission planning, making it the go-to solution for any *MAVLink-enabled drone*.

---

### 🌟 *Why Choose QGroundControl?*

- *🚀 Ease of Use*: A beginner-friendly interface designed for smooth operation without sacrificing advanced features for pros.
- *✈️ Comprehensive Flight Control*: Full flight control and mission management for *PX4* and *ArduPilot* powered UAVs.
- *🛠️ Mission Planning*: Easily plan complex missions with a simple drag-and-drop interface.

🔍 For a deeper dive into using QGC, check out the [User Manual](https://docs.qgroundcontrol.com/en/) – although, thanks to QGC's intuitive UI, you may not even need it!


---

### 🚁 *Key Features*

- 🕹️ *Full Flight Control*: Supports all *MAVLink drones*.
- ⚙️ *Vehicle Setup*: Tailored configuration for *PX4* and *ArduPilot* platforms.
- 🔧 *Fully Open Source*: Customize and extend the software to suit your needs.

🎯 Check out the latest updates in our [New Features and Release Notes](https://github.com/mavlink/qgroundcontrol/blob/master/ChangeLog.md).

---

### 💻 *Get Involved!*

QGroundControl is *open-source*, meaning you have the power to shape it! Whether you're fixing bugs, adding features, or customizing for your specific needs, QGC welcomes contributions from the community.

🛠️ Start building today with our [Developer Guide](https://dev.qgroundcontrol.com/en/) and [build instructions](https://dev.qgroundcontrol.com/en/getting_started/).

---

### 🔗 *Useful Links*

- 🌐 [Official Website](http://qgroundcontrol.com)
- 📘 [User Manual](https://docs.qgroundcontrol.com/en/)
- 🛠️ [Developer Guide](https://dev.qgroundcontrol.com/en/)
- 💬 [Discussion & Support](https://docs.qgroundcontrol.com/en/Support/Support.html)
- 🤝 [Contributing](https://dev.qgroundcontrol.com/en/contribute/)
- 📜 [License Information](https://github.com/mavlink/qgroundcontrol/blob/master/.github/COPYING.md)

---

With QGroundControl, you're in full command of your UAV, ready to take your missions to the next level.

---

# QDC v5（Custom QGroundControl）

**本リポジトリは公式 QGroundControl ではありません。**

このリポジトリは、オープンソースプロジェクトであるQGroundControl（QGC）をベースに、特定用途向けのカスタマイズを行ったものです。
主に、プロジェクト要件に対応するためのUI調整・機能追加・構成整理を含んでいます。

---

## リポジトリ

本プロジェクトは、公式の QGroundControl リポジトリを元にしたカスタマイズ版です。

以下のような変更・追加を含みます：

- プロジェクト固有の UI / QML 拡張
- 不要な生成物や機密情報を含まないための構成整理



---

## ディレクトリ構成

主要なディレクトリの概要は以下のとおりです。

- `src/` – QGC 本体のソースコード
- `custom/` – 本プロジェクト固有のカスタマイズ
- `android/` – Android 向けビルド設定
- `cmake/` – CMake 補助スクリプト・ツールチェイン
- `docs/` – ドキュメント
- `resources/` – 画像・フォント等のリソース

---

## ビルドに関する注意

- Android ビルドには、ローカル環境での署名設定が必要です。
- 署名関連ファイルは本リポジトリには含まれていません。

---

## ライセンス

本プロジェクトはQGroundControlをベースとしており、  
ライセンスは元プロジェクトの条件に従います。

(https://github.com/mavlink/qgroundcontrol/blob/master/.github/COPYING.md)
