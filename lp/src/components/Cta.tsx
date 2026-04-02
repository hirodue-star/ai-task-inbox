export function Cta() {
  return (
    <section className="py-20 px-6 bg-gradient-to-b from-[#0B0B2B] to-[#1A1A60] text-center">
      <div className="max-w-2xl mx-auto">
        {/* 黄金ロゴ */}
        <div
          className="w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-8"
          style={{
            background: "linear-gradient(135deg, #FFF8DC, #FFD700, #C8960C)",
            boxShadow: "0 0 40px rgba(255, 215, 0, 0.3)",
          }}
        >
          <span className="text-3xl font-black text-[#5C3D10]">MA</span>
        </div>

        <h2 className="text-3xl sm:text-4xl font-black text-white mb-4 leading-tight">
          今日の「お手伝い」が<br />
          <span className="text-[#FFD700]">合格通知</span>に変わる
        </h2>

        <p className="text-white/50 mb-8 max-w-md mx-auto leading-relaxed">
          子供は毎日成長しています。<br />
          記録しなかった日の成長は、二度と取り戻せません。
        </p>

        <a
          href="#pricing"
          className="inline-block px-12 py-5 rounded-full text-lg font-bold text-[#5C3D10] transition-all hover:scale-105 active:scale-95"
          style={{
            background: "linear-gradient(135deg, #FFF8DC, #FFD700, #C8960C)",
            boxShadow: "0 8px 30px rgba(255, 215, 0, 0.4)",
          }}
        >
          無料で始める
        </a>

        <div className="flex items-center justify-center gap-6 mt-8 text-white/30 text-sm">
          <span>7日間無料</span>
          <span>・</span>
          <span>カード不要</span>
          <span>・</span>
          <span>即キャンセル可</span>
        </div>
      </div>
    </section>
  );
}
