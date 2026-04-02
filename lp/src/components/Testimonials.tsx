const testimonials = [
  {
    text: "お手伝いを嫌がっていた息子が、メダルが欲しくて自分から洗い物を始めました。面接練習でも「お皿洗いが得意です」と堂々と話せるようになりました。",
    author: "東京都 Aさん（年長ママ）",
    result: "志望校合格",
  },
  {
    text: "漫画日記を毎晩一緒に振り返るのが家族の習慣になりました。「なぜそうしたの？」という問いかけで、娘の言語化力が見違えるほど伸びました。",
    author: "神奈川県 Bさん（年中ママ）",
    result: "面接A評価",
  },
  {
    text: "願書に何を書くか悩んでいたのですが、AIの「5つの強み」レポートがそのまま使えました。データに基づいた内容なので説得力が違います。",
    author: "大阪府 Cさん（年長パパ）",
    result: "願書通過",
  },
];

export function Testimonials() {
  return (
    <section className="py-20 px-6 bg-white">
      <div className="max-w-4xl mx-auto">
        <p className="text-center text-sm font-bold text-[#C8960C] tracking-widest mb-2">
          VOICES
        </p>
        <h2 className="text-3xl sm:text-4xl font-black text-center text-[#2C3E50] mb-12">
          先輩ママの<span className="text-[#C8960C]">声</span>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {testimonials.map((t, i) => (
            <div key={i} className="p-6 rounded-2xl bg-[#FAFAF8] border border-[#F0EDE8]">
              {/* 星 */}
              <div className="flex gap-1 mb-3">
                {[...Array(5)].map((_, j) => (
                  <span key={j} className="text-[#FFD700]">★</span>
                ))}
              </div>
              <p className="text-sm text-[#2C3E50]/80 leading-relaxed mb-4">
                {t.text}
              </p>
              <div className="flex items-center justify-between">
                <p className="text-xs text-[#5C3D10]/40">{t.author}</p>
                <span className="px-2 py-1 rounded-full bg-[#E8F5E9] text-xs font-bold text-[#2E7D32]">
                  {t.result}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
