const features = [
  {
    icon: "🔍",
    title: "観察力",
    subtitle: "Observation",
    desc: "日常の写真撮影と漫画変換で、「見る力」を養います。行動観察テストで評価される注意力の基礎を、遊びながら鍛えます。",
    badge: "行動観察対策",
    gradient: "from-[#E8F5E9] to-[#C8E6C9]",
    borderColor: "border-[#4CAF50]/20",
  },
  {
    icon: "💝",
    title: "ホスピタリティ",
    subtitle: "Hospitality",
    desc: "お手伝い記録と家族SNSで、「思いやり」を可視化。面接で「お友達を助けた経験」を自分の言葉で語れる子に育てます。",
    badge: "面接対策",
    gradient: "from-[#FCE4EC] to-[#F8BBD0]",
    borderColor: "border-[#E91E63]/20",
  },
  {
    icon: "📖",
    title: "ポートフォリオ",
    subtitle: "Portfolio",
    desc: "漫画日記が自動的にデジタル作品集に。願書に添付できる「お子様の5つの強み」レポートをAIが生成します。",
    badge: "願書活用",
    gradient: "from-[#FFF3E0] to-[#FFE0B2]",
    borderColor: "border-[#FF9800]/20",
  },
];

export function Features() {
  return (
    <section className="py-20 px-6 bg-[#FAFAF8]" id="features">
      <div className="max-w-5xl mx-auto">
        <p className="text-center text-sm font-bold text-[#C8960C] tracking-widest mb-2">
          EDUCATION ENGINE
        </p>
        <h2 className="text-3xl sm:text-4xl font-black text-center text-[#2C3E50] mb-4">
          私立入学に必要な<span className="text-[#C8960C]">3つの力</span>
        </h2>
        <p className="text-center text-[#5C3D10]/50 mb-12 max-w-lg mx-auto">
          MA-LOGICは、日常生活の中で入試に必要な能力を自然に養う唯一のアプリです
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {features.map((f, i) => (
            <div
              key={i}
              className={`relative p-8 rounded-3xl bg-gradient-to-b ${f.gradient} border ${f.borderColor} transition-transform hover:scale-[1.02]`}
            >
              {/* バッジ */}
              <div className="absolute top-4 right-4 px-3 py-1 rounded-full bg-white/60 text-xs font-bold text-[#2C3E50]/60">
                {f.badge}
              </div>

              <span className="text-5xl block mb-4">{f.icon}</span>
              <h3 className="text-xl font-black text-[#2C3E50] mb-1">{f.title}</h3>
              <p className="text-xs text-[#5C3D10]/40 tracking-wider mb-4">{f.subtitle}</p>
              <p className="text-sm text-[#2C3E50]/70 leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>

        {/* 権威性 */}
        <div className="mt-16 text-center">
          <p className="text-sm text-[#5C3D10]/30">
            HLC理論（Hospitality / Logical / Creative）に基づく独自の教育フレームワーク
          </p>
        </div>
      </div>
    </section>
  );
}
