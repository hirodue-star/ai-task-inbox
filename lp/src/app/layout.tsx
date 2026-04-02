import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "MA-LOGIC | 遊びが、合格へ。",
  description: "お手伝い×知育×漫画日記。子供の「やりたい」が私立入学の力になる、家族のための成長プラットフォーム。",
  openGraph: {
    title: "MA-LOGIC | 遊びが、合格へ。",
    description: "お手伝い×知育×漫画日記。家族の成長プラットフォーム。",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
