"use client";

const plans = [
  {
    name: "スタンダード",
    price: "980",
    yearlyPrice: "9,800",
    yearlyNote: "年額一括で2ヶ月分無料",
    features: [
      "無制限の思い出記録",
      "漫画変換（オンデバイス）",
      "ぬりえモード",
      "デイリーミッション",
      "家族タイムライン",
      "成長ダッシュボード",
    ],
    cta: "7日間無料で試す",
    recommended: false,
  },
  {
    name: "プレミアム",
    price: "1,980",
    yearlyPrice: "19,800",
    yearlyNote: "年額一括で2ヶ月分無料",
    features: [
      "スタンダードの全機能",
      "AI強み分析レポート",
      "デジタル漫画本の自動生成",
      "記念日AI変換（月5回）",
      "PDFエクスポート",
      "願書用データレポート",
      "優先サポート",
    ],
    cta: "7日間無料で試す",
    recommended: true,
  },
];

export function Pricing() {
  return (
    <section className="py-20 px-6 bg-gradient-to-b from-[#FAFAF8] to-[#FFF8F0]" id="pricing">
      <div className="max-w-4xl mx-auto">
        <p className="text-center text-sm font-bold text-[#C8960C] tracking-widest mb-2">
          PRICING
        </p>
        <h2 className="text-3xl sm:text-4xl font-black text-center text-[#2C3E50] mb-4">
          お子様の未来への<span className="text-[#C8960C]">投資</span>
        </h2>
        <p className="text-center text-[#5C3D10]/50 mb-4">
          塾1回分の費用で、毎日の成長を記録
        </p>
        <p className="text-center text-sm text-[#C8960C] font-bold mb-12">
          年額プランなら2ヶ月分無料
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl mx-auto">
          {plans.map((plan, i) => (
            <div
              key={i}
              className={`relative p-8 rounded-3xl transition-transform hover:scale-[1.02] ${
                plan.recommended
                  ? "border-2 border-[#FFD700] shadow-xl"
                  : "border border-[#E8E4DE]"
              }`}
              style={{
                background: plan.recommended
                  ? "linear-gradient(180deg, #FFFDF5, #FFF8DC)"
                  : "white",
              }}
            >
              {plan.recommended && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full text-xs font-bold text-[#5C3D10]"
                  style={{ background: "linear-gradient(135deg, #FFD700, #C8960C)" }}>
                  一番人気
                </div>
              )}

              <h3 className="text-xl font-black text-[#2C3E50] mb-2">{plan.name}</h3>

              <div className="flex items-baseline gap-1 mb-1">
                <span className="text-4xl font-black text-[#2C3E50]">¥{plan.price}</span>
                <span className="text-sm text-[#5C3D10]/50">/ 月</span>
              </div>
              <p className="text-xs text-[#C8960C] font-bold mb-6">
                年額 ¥{plan.yearlyPrice}（{plan.yearlyNote}）
              </p>

              <ul className="space-y-3 mb-8">
                {plan.features.map((f, j) => (
                  <li key={j} className="flex items-start gap-2 text-sm text-[#2C3E50]/70">
                    <span className={`mt-0.5 ${plan.recommended ? "text-[#FFD700]" : "text-[#4CAF50]"}`}>✓</span>
                    {f}
                  </li>
                ))}
              </ul>

              <button
                className={`w-full py-4 rounded-2xl text-base font-bold transition-all hover:scale-[1.02] active:scale-95 ${
                  plan.recommended
                    ? "text-[#5C3D10]"
                    : "bg-[#2C3E50] text-white"
                }`}
                style={plan.recommended ? {
                  background: "linear-gradient(135deg, #FFF8DC, #FFD700, #C8960C)",
                  boxShadow: "0 4px 20px rgba(255, 215, 0, 0.3)",
                } : undefined}
              >
                {plan.cta}
              </button>
            </div>
          ))}
        </div>

        <p className="text-center text-xs text-[#5C3D10]/30 mt-8">
          7日間の無料トライアル後に自動課金 ・ いつでもキャンセル可能
        </p>
      </div>
    </section>
  );
}
