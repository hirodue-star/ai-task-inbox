"use client";
import { useEffect, useRef, useState } from "react";

const steps = [
  { emoji: "📸", title: "写真を撮る", desc: "日常の一コマをパシャリ" },
  { emoji: "🖊️", title: "漫画に変換", desc: "AIが線画に自動変換（無料）" },
  { emoji: "🎨", title: "ぬりえで遊ぶ", desc: "巧緻性トレーニング" },
  { emoji: "📖", title: "漫画本になる", desc: "30件で創刊号が自動生成" },
];

export function Demo() {
  const [activeStep, setActiveStep] = useState(0);
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          const interval = setInterval(() => {
            setActiveStep((prev) => (prev + 1) % steps.length);
          }, 2000);
          return () => clearInterval(interval);
        }
      },
      { threshold: 0.3 }
    );
    if (sectionRef.current) observer.observe(sectionRef.current);
    return () => observer.disconnect();
  }, []);

  return (
    <section ref={sectionRef} className="py-20 px-6 bg-white">
      <div className="max-w-4xl mx-auto">
        <h2 className="text-3xl sm:text-4xl font-black text-center text-[#2C3E50] mb-4">
          毎日の写真が、<span className="text-[#C8960C]">宝物</span>になる
        </h2>
        <p className="text-center text-[#5C3D10]/50 mb-12">
          写真 → 漫画変換 → ぬりえ → 漫画本。すべてスマホ内で完結。API課金ゼロ。
        </p>

        {/* ステップアニメーション */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4 sm:gap-2">
          {steps.map((step, i) => (
            <div key={i} className="flex items-center">
              <div
                className={`flex flex-col items-center p-6 rounded-2xl transition-all duration-500 w-40 ${
                  activeStep === i
                    ? "bg-gradient-to-b from-[#FFF8DC] to-[#FFE8B5] scale-110 shadow-lg"
                    : "bg-gray-50 scale-100"
                }`}
              >
                <span className="text-4xl mb-3">{step.emoji}</span>
                <p className="font-bold text-sm text-[#2C3E50]">{step.title}</p>
                <p className="text-xs text-[#5C3D10]/50 mt-1 text-center">{step.desc}</p>
              </div>
              {i < steps.length - 1 && (
                <svg className="hidden sm:block w-8 h-8 text-[#FFD700]/40 mx-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                  <path d="M9 5l7 7-7 7"/>
                </svg>
              )}
            </div>
          ))}
        </div>

        {/* モックアップ */}
        <div className="mt-16 flex justify-center">
          <div className="relative w-64 h-[500px] bg-[#0B0B2B] rounded-[40px] p-3 shadow-2xl">
            <div className="w-full h-full rounded-[32px] bg-gradient-to-b from-[#1A1A60] to-[#0B0B2B] flex flex-col items-center justify-center overflow-hidden">
              {/* マンダラグリッド */}
              <div className="w-40 h-40 relative mb-4">
                <svg viewBox="0 0 160 160" className="w-full h-full">
                  <rect x="2" y="2" width="156" height="156" rx="8" stroke="#FFD700" strokeWidth="2" fill="none"/>
                  <line x1="54" y1="2" x2="54" y2="158" stroke="#FFD700" strokeWidth="1" opacity="0.6"/>
                  <line x1="106" y1="2" x2="106" y2="158" stroke="#FFD700" strokeWidth="1" opacity="0.6"/>
                  <line x1="2" y1="54" x2="158" y2="54" stroke="#FFD700" strokeWidth="1" opacity="0.6"/>
                  <line x1="2" y1="106" x2="158" y2="106" stroke="#FFD700" strokeWidth="1" opacity="0.6"/>
                  <circle cx="80" cy="80" r="20" stroke="#FFD700" strokeWidth="0.8" fill="rgba(255,215,0,0.1)"/>
                  <circle cx="80" cy="80" r="12" stroke="#FFD700" strokeWidth="0.5" fill="none" opacity="0.5"/>
                </svg>
              </div>
              <p className="text-[#FFD700] text-sm font-bold tracking-widest">MANDALA</p>
              <p className="text-white/30 text-xs mt-1">思考の遺跡を完成させよ</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
