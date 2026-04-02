"use client";

export function Hero() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden bg-gradient-to-b from-[#FFFDF5] via-[#FFF8F0] to-[#FFE8D0] px-6">
      {/* 背景装飾 */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {/* マンダラグリッド（黄金） */}
        <div className="absolute top-10 right-[-60px] w-64 h-64 opacity-10">
          <svg viewBox="0 0 300 300" fill="none">
            <rect x="10" y="10" width="280" height="280" rx="12" stroke="#FFD700" strokeWidth="3"/>
            <line x1="100" y1="10" x2="100" y2="290" stroke="#FFD700" strokeWidth="1.5"/>
            <line x1="200" y1="10" x2="200" y2="290" stroke="#FFD700" strokeWidth="1.5"/>
            <line x1="10" y1="100" x2="290" y2="100" stroke="#FFD700" strokeWidth="1.5"/>
            <line x1="10" y1="200" x2="290" y2="200" stroke="#FFD700" strokeWidth="1.5"/>
            <circle cx="150" cy="150" r="40" stroke="#FFD700" strokeWidth="1" opacity="0.5"/>
          </svg>
        </div>
        {/* ぷにぷにバブル */}
        {[
          { x: "10%", y: "20%", size: "80px", color: "#FFB5C5", delay: "0s" },
          { x: "80%", y: "15%", size: "60px", color: "#B5D8FF", delay: "1s" },
          { x: "20%", y: "70%", size: "50px", color: "#B5FFCA", delay: "0.5s" },
          { x: "70%", y: "75%", size: "70px", color: "#FFECB5", delay: "1.5s" },
        ].map((b, i) => (
          <div
            key={i}
            className="absolute rounded-full opacity-30"
            style={{
              left: b.x, top: b.y, width: b.size, height: b.size,
              background: `radial-gradient(circle at 30% 30%, white, ${b.color})`,
              animation: `float 3s ease-in-out ${b.delay} infinite`,
            }}
          />
        ))}
      </div>

      {/* ロゴ */}
      <div
        className="relative w-24 h-24 rounded-full flex items-center justify-center mb-8"
        style={{
          background: "linear-gradient(135deg, #FFF8DC, #FFD700, #C8960C, #FFD700)",
          animation: "pulse-gold 2s ease-in-out infinite",
        }}
      >
        <span className="text-4xl font-black text-[#5C3D10] tracking-wider">MA</span>
      </div>

      {/* キャッチコピー */}
      <h1 className="text-4xl sm:text-5xl md:text-6xl font-black text-center text-[#2C3E50] leading-tight mb-4">
        <span className="block">日記で、</span>
        <span className="block">わが子の</span>
        <span
          className="block bg-clip-text text-transparent"
          style={{ backgroundImage: "linear-gradient(135deg, #FFD700, #C8960C)" }}
        >
          強みが見える。
        </span>
      </h1>

      <p className="text-lg sm:text-xl text-center text-[#5C3D10]/70 max-w-md mb-8 leading-relaxed">
        写真を撮って日記を書くだけ。<br />
        AIがお子様の「思いやり」「論理力」「創造性」を<br />
        リアルタイムで可視化します。
      </p>

      {/* CTA */}
      <a
        href="#pricing"
        className="relative px-10 py-4 rounded-full text-lg font-bold text-[#5C3D10] transition-all hover:scale-105 active:scale-95"
        style={{
          background: "linear-gradient(135deg, #FFF8DC, #FFD700, #C8960C)",
          boxShadow: "0 8px 30px rgba(255, 215, 0, 0.4)",
        }}
      >
        7日間無料で始める
      </a>

      <p className="mt-4 text-sm text-[#5C3D10]/40">
        クレジットカード不要 ・ いつでもキャンセル
      </p>

      {/* スクロールヒント */}
      <div className="absolute bottom-8 flex flex-col items-center opacity-40">
        <p className="text-xs text-[#5C3D10] mb-2">scroll</p>
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#5C3D10" strokeWidth="2">
          <path d="M7 13l5 5 5-5M7 6l5 5 5-5"/>
        </svg>
      </div>
    </section>
  );
}
