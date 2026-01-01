
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Mail, Trash2, CheckCircle, Clock } from "lucide-react";
import { SwalFire } from "@/utils/sweetalert";

interface Message {
    id: string;
    name: string;
    email: string;
    subject: string;
    message: string;
    read: boolean;
    created_at: string;
}

export function AdminMessages() {
    const [messages, setMessages] = useState<Message[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchMessages();
    }, []);

    const fetchMessages = async () => {
        const { data, error } = await (supabase
            .from("messages") as any)
            .select("*")
            .order("created_at", { ascending: false });

        if (error) {
            console.error(error);
        } else {
            setMessages(data || []);
        }
        setLoading(false);
    };

    const handleDelete = async (id: string) => {
        if (!(await SwalFire.confirm("ยืนยันการลบข้อความนี้?"))) return;

        const { error } = await (supabase.from("messages") as any).delete().eq("id", id);
        if (!error) {
            SwalFire.success("ลบข้อความเรียบร้อย");
            fetchMessages();
        }
    };

    const handleToggleRead = async (id: string, currentStatus: boolean) => {
        const { error } = await (supabase.from("messages") as any).update({ read: !currentStatus }).eq("id", id);
        if (!error) {
            fetchMessages();
        }
    };

    if (loading) return <div>กำลังโหลดข้อความ...</div>;

    return (
        <Card>
            <CardHeader>
                <CardTitle className="flex items-center gap-2">
                    <Mail className="w-5 h-5" />
                    ข้อความจากผู้เยี่ยมชม ({messages.length})
                </CardTitle>
                <CardDescription>จัดการข้อความที่ส่งผ่านแบบฟอร์มหน้าเว็บไซต์</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
                {messages.length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">ยังไม่มีข้อความใหม่</div>
                ) : (
                    messages.map((msg) => (
                        <div key={msg.id} className={`p-4 rounded-lg border ${msg.read ? 'bg-muted/30 border-border' : 'bg-primary/5 border-primary/20'} transition-all`}>
                            <div className="flex justify-between items-start mb-2">
                                <div>
                                    <h4 className="font-semibold text-lg">{msg.subject || "(ไม่มีหัวข้อ)"}</h4>
                                    <div className="text-sm text-muted-foreground flex items-center gap-2">
                                        <span className="font-medium text-foreground">{msg.name}</span>
                                        <span>({msg.email})</span>
                                        <span>•</span>
                                        <span className="flex items-center gap-1">
                                            <Clock className="w-3 h-3" />
                                            {new Date(msg.created_at).toLocaleString('th-TH')}
                                        </span>
                                    </div>
                                </div>
                                <div className="flex gap-2">
                                    <Button
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => handleToggleRead(msg.id, msg.read)}
                                        title={msg.read ? "ทำเครื่องหมายว่ายังไม่ร่าน" : "ทำเครื่องหมายว่าอ่านแล้ว"}
                                    >
                                        <CheckCircle className={`w-4 h-4 ${msg.read ? 'text-green-500' : 'text-gray-300'}`} />
                                    </Button>
                                    <Button
                                        variant="ghost"
                                        size="sm"
                                        className="text-destructive hover:bg-destructive/10"
                                        onClick={() => handleDelete(msg.id)}
                                    >
                                        <Trash2 className="w-4 h-4" />
                                    </Button>
                                </div>
                            </div>
                            <p className="text-sm leading-relaxed whitespace-pre-wrap">{msg.message}</p>
                        </div>
                    ))
                )}
            </CardContent>
        </Card>
    );
}
