export function Footer() {
  return (
    <footer className="py-10 px-6 bg-[#FAFAF8] border-t border-[#F0EDE8]">
      <div className="max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-2">
          <div
            className="w-8 h-8 rounded-full flex items-center justify-center"
            style={{ background: "linear-gradient(135deg, #FFD700, #C8960C)" }}
          >
            <span className="text-xs font-black text-[#5C3D10]">MA</span>
          </div>
          <span className="text-sm font-bold text-[#2C3E50]">MA-LOGIC</span>
        </div>
        <div className="flex gap-6 text-xs text-[#5C3D10]/40">
          <a href="#" className="hover:text-[#5C3D10]/70">利用規約</a>
          <a href="#" className="hover:text-[#5C3D10]/70">プライバシーポリシー</a>
          <a href="#" className="hover:text-[#5C3D10]/70">特定商取引法</a>
          <a href="#" className="hover:text-[#5C3D10]/70">お問い合わせ</a>
        </div>
        <p className="text-xs text-[#5C3D10]/30">
          &copy; 2026 MA-LOGIC. All rights reserved.
        </p>
      </div>
    </footer>
  );
}
