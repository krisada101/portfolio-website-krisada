import { useEffect, useState } from "react";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import {
  Target,
  BookOpen,
  Users,
  TrendingUp,
  FileText,
  Image as ImageIcon,
  Video,
  Link as LinkIcon,
  ChevronDown,
  ChevronUp,
  Sparkles,
  Star,
  Award,
  ExternalLink,
  Loader2,
  X
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";

interface PACategory {
  id: string;
  category_number: number;
  title: string;
  icon: string;
  color: string;
}

interface PAIndicator {
  id: string;
  category_id: string;
  indicator_number: string;
  name: string;
  description: string | null;
}

interface PAWork {
  id: string;
  indicator_id: string;
  work_type: string;
  title: string;
  url: string | null;
}

interface PAImage {
  id: string;
  indicator_id: string;
  image_url: string;
  caption: string | null;
}

const iconMap: Record<string, any> = {
  BookOpen,
  Users,
  TrendingUp,
};

const getWorkIcon = (type: string) => {
  switch (type) {
    case "document": return FileText;
    case "image": return ImageIcon;
    case "video": return Video;
    case "link": return LinkIcon;
    default: return FileText;
  }
};

const getWorkColor = (type: string) => {
  switch (type) {
    case "document": return "bg-primary/10 text-primary";
    case "image": return "bg-secondary/10 text-secondary";
    case "video": return "bg-coral/10 text-coral";
    case "link": return "bg-accent/10 text-accent";
    default: return "bg-primary/5 text-primary";
  }
};

// Helper Component for Image Gallery (Stateless)
function ImageGallery({
  images,
  onViewImage
}: {
  images: PAImage[];
  onViewImage: (url: string) => void;
}) {
  const [isOpen, setIsOpen] = useState(true);

  if (images.length === 0) return null;

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen} className="mt-4">
      <CollapsibleTrigger className="flex items-center gap-2 text-sm text-primary hover:text-primary/80 transition-colors">
        <ImageIcon className="w-4 h-4" />
        <span>รูปภาพประกอบ ({images.length} รูป)</span>
        {isOpen ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
      </CollapsibleTrigger>
      <CollapsibleContent className="mt-3">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {images.map((img) => (
            <div
              key={img.id}
              className="relative aspect-square rounded-xl overflow-hidden border border-border cursor-pointer group"
              onClick={() => onViewImage(img.image_url)}
            >
              <img
                src={img.image_url}
                alt={img.caption || "รูปภาพประกอบ"}
                className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110"
              />
              <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors" />
            </div>
          ))}
        </div>
      </CollapsibleContent>
    </Collapsible>
  );
}

function IndicatorCard({
  indicator,
  categoryColor,
  works,
  images,
  onViewImage
}: {
  indicator: PAIndicator;
  categoryColor: string;
  works: PAWork[];
  images: PAImage[];
  onViewImage: (url: string) => void;
}) {
  const [isOpen, setIsOpen] = useState(true);

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <Card className="border border-border/50 shadow-soft hover:shadow-lg transition-all duration-300">
        <CollapsibleTrigger asChild>
          <CardHeader className="cursor-pointer hover:bg-muted/30 transition-colors">
            <div className="flex items-center justify-between">
              <div className="flex items-start gap-3">
                <Badge className={`bg-gradient-to-r ${categoryColor} text-white`}>
                  {indicator.indicator_number}
                </Badge>
                <div>
                  <CardTitle className="text-base font-semibold text-foreground leading-relaxed">
                    {indicator.name}
                  </CardTitle>
                  {indicator.description && (
                    <p className="text-sm text-muted-foreground mt-1 leading-relaxed">
                      {indicator.description}
                    </p>
                  )}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <Badge variant="outline" className="text-xs">
                  {works.length} ผลงาน
                </Badge>
                {isOpen ? (
                  <ChevronUp className="w-5 h-5 text-muted-foreground" />
                ) : (
                  <ChevronDown className="w-5 h-5 text-muted-foreground" />
                )}
              </div>
            </div>
          </CardHeader>
        </CollapsibleTrigger>
        <CollapsibleContent>
          <CardContent className="pt-0">
            {/* Works */}
            {works.length > 0 ? (
              <div className="grid gap-3">
                {works.map((work) => {
                  const WorkIcon = getWorkIcon(work.work_type);
                  const colorClass = getWorkColor(work.work_type);
                  return (
                    <a
                      key={work.id}
                      href={work.url || "#"}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-3 p-3 rounded-xl bg-muted/30 hover:bg-muted/50 transition-all duration-200 group"
                    >
                      <div className={`p-2 rounded-lg ${colorClass}`}>
                        <WorkIcon className="w-4 h-4" />
                      </div>
                      <span className="flex-1 text-sm text-foreground group-hover:text-primary transition-colors">
                        {work.title}
                      </span>
                      {work.url && (
                        <ExternalLink className="w-4 h-4 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity" />
                      )}
                    </a>
                  );
                })}
              </div>
            ) : (
              <p className="text-sm text-muted-foreground text-center py-4">ยังไม่มีผลงาน</p>
            )}

            {/* Image Gallery */}
            <ImageGallery images={images} onViewImage={onViewImage} />
          </CardContent>
        </CollapsibleContent>
      </Card>
    </Collapsible>
  );
}

export default function PerformanceEvaluation() {
  const [categories, setCategories] = useState<PACategory[]>([]);
  const [indicators, setIndicators] = useState<PAIndicator[]>([]);
  const [works, setWorks] = useState<PAWork[]>([]);
  const [images, setImages] = useState<PAImage[]>([]);
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [viewingImage, setViewingImage] = useState<string | null>(null);

  // Scroll to top on page load
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "instant" });
  }, []);

  useEffect(() => {
    const fetchData = async () => {
      const [catRes, indRes, workRes, imgRes, profileRes] = await Promise.all([
        supabase.from("pa_categories").select("*").order("category_number"),
        supabase.from("pa_indicators").select("*").order("indicator_number"),
        supabase.from("pa_works").select("*").order("sort_order"),
        supabase.from("pa_indicator_images").select("*").order("sort_order"),
        supabase.from("profiles").select("pa_description, pa_header_title, pa_header_subtitle, pa_badge_text").single(),
      ]);

      if (catRes.data) setCategories(catRes.data);
      if (indRes.data) setIndicators(indRes.data);
      if (workRes.data) setWorks(workRes.data);
      if (imgRes.data) setImages(imgRes.data);
      if (profileRes.data) setProfile(profileRes.data);
      setLoading(false);
    };

    fetchData();
  }, []);

  const getIndicatorWorks = (indicatorId: string) => works.filter(w => w.indicator_id === indicatorId);
  const getIndicatorImages = (indicatorId: string) => images.filter(i => i.indicator_id === indicatorId);
  const getCategoryIndicators = (categoryId: string) => indicators.filter(i => i.category_id === categoryId);

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main className="pt-20 pb-16">
        {/* Hero Section */}
        <section className="relative py-16 overflow-hidden">
          <div className="absolute inset-0 pattern-dots opacity-30" />
          <div className="absolute inset-0 bg-gradient-hero" />

          {/* Floating Elements */}
          <div className="absolute top-10 left-10 animate-float">
            <Target className="w-8 h-8 text-primary" />
          </div>
          <div className="absolute top-20 right-20 animate-float" style={{ animationDelay: "1s" }}>
            <Award className="w-6 h-6 text-accent" />
          </div>
          <div className="absolute bottom-10 left-20 animate-float" style={{ animationDelay: "2s" }}>
            <Star className="w-7 h-7 text-secondary" fill="currentColor" />
          </div>

          <div className="container mx-auto px-4 relative z-10">
            <div className="text-center max-w-3xl mx-auto">
              <div className="inline-flex items-center gap-2 bg-primary/10 text-primary px-4 py-2 rounded-full mb-6 animate-fade-in">
                <Sparkles className="w-4 h-4" />
                <span className="text-sm font-medium">{profile?.pa_badge_text || "Performance Agreement (PA)"}</span>
              </div>

              <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-foreground mb-6 animate-fade-in leading-tight" style={{ animationDelay: "0.1s" }}>
                <span className="block mb-3">{profile?.pa_header_title || "ข้อตกลงในการพัฒนางาน"}</span>
                <span className="text-gradient-primary block leading-normal">{profile?.pa_header_subtitle || "วPA (Performance Agreement)"}</span>
              </h1>

              <p className="text-lg text-muted-foreground animate-fade-in leading-relaxed" style={{ animationDelay: "0.2s" }}>
                {profile?.pa_description ? (
                  profile.pa_description.split('\n').map((line: string, i: number) => (
                    <span key={i} className="block">
                      {line}
                    </span>
                  ))
                ) : (
                  <>
                    รวบรวมผลงานและหลักฐานการปฏิบัติงานตามเกณฑ์ วPA
                    <br className="hidden sm:block" />
                    สำหรับข้าราชการครูและบุคลากรทางการศึกษา ปีงบประมาณ 2569
                  </>
                )}
              </p>
            </div>
          </div>
        </section>

        {/* PA Categories */}
        <section className="py-12">
          <div className="container mx-auto px-4">
            {loading ? (
              <div className="flex items-center justify-center py-20">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
              </div>
            ) : categories.length === 0 ? (
              <div className="text-center py-20">
                <p className="text-muted-foreground">ยังไม่มีข้อมูล กรุณาเพิ่มข้อมูลผ่านระบบจัดการหลังบ้าน</p>
              </div>
            ) : (
              <div className="max-w-4xl mx-auto space-y-12">
                {categories.map((category, catIndex) => {
                  const IconComp = iconMap[category.icon] || BookOpen;
                  const categoryIndicators = getCategoryIndicators(category.id);

                  return (
                    <div
                      key={category.id}
                      className="animate-fade-in"
                      style={{ animationDelay: `${catIndex * 0.1}s` }}
                    >
                      {/* Category Header */}
                      <div className="flex items-center gap-4 mb-6">
                        <div className={`w-14 h-14 rounded-2xl bg-${category.color}-100 flex items-center justify-center`}>
                          <IconComp className={`w-7 h-7 text-${category.color}-600`} />
                        </div>
                        <div>
                          <h2 className="text-xl md:text-2xl font-bold text-foreground leading-relaxed">
                            {category.title}
                          </h2>
                          <p className="text-sm text-muted-foreground">
                            {categoryIndicators.length} ตัวชี้วัด
                          </p>
                        </div>
                      </div>

                      {/* Indicators */}
                      <div className="space-y-4 pl-0 md:pl-[4.5rem]">
                        {categoryIndicators.length === 0 ? (
                          <p className="text-sm text-muted-foreground">ยังไม่มีตัวชี้วัด</p>
                        ) : (
                          categoryIndicators.map((indicator) => (
                            <IndicatorCard
                              key={indicator.id}
                              indicator={indicator}
                              categoryColor={category.color}
                              works={getIndicatorWorks(indicator.id)}
                              images={getIndicatorImages(indicator.id)}
                              onViewImage={setViewingImage}
                            />
                          ))
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </section>
      </main>

      {/* Global Image Modal */}
      {viewingImage && (
        <div
          className="fixed inset-0 z-[9999] flex items-center justify-center p-8 animate-in fade-in duration-200"
          onClick={() => setViewingImage(null)}
        >
          {/* Invisible backdrop */}
          <div className="absolute inset-0 bg-transparent" />

          {/* Image Frame */}
          <div
            className="relative z-[10000] bg-white p-2 rounded-xl shadow-2xl border border-white/20"
            onClick={(e) => e.stopPropagation()}
          >
            <Button
              size="icon"
              variant="destructive"
              className="absolute -top-3 -right-3 h-8 w-8 rounded-full shadow-lg border-2 border-white hover:bg-destructive/90 transition-transform hover:scale-105"
              onClick={(e) => {
                e.stopPropagation();
                setViewingImage(null);
              }}
            >
              <X className="w-4 h-4" />
              <span className="sr-only">Close</span>
            </Button>

            <img
              src={viewingImage}
              alt="รูปภาพขยาย"
              className="max-w-full max-h-[85vh] w-auto h-auto rounded-lg"
            />
          </div>
        </div>
      )}

      <Footer />
    </div>
  );
}
