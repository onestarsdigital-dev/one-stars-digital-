
import React from 'react';
import { 
  LayoutDashboard, 
  Settings, 
  MessageSquare, 
  Globe, 
  Wallet, 
  UserCheck, 
  ShieldAlert, 
  LogOut, 
  Users, 
  GraduationCap, 
  Layout,
  Wand2,
  CreditCard,
  Layers,
  ShoppingBag,
  Zap,
  X,
  ClipboardList,
  ShieldCheck,
  Briefcase,
  Award,
  Store,
  Banknote,
  Bot,
  Bell,
  LifeBuoy,
  BarChart4,
  ShieldEllipsis,
  Fingerprint
} from 'lucide-react';
import { ViewType } from './types';

interface SidebarProps {
  currentView: ViewType;
  onViewChange: (view: any) => void;
  onViewPublicSite: () => void;
  onLogout: () => void;
  isOpen: boolean;
  onClose: () => void;
}

const Logo = () => (
  <svg viewBox="0 0 200 120" className="w-full h-auto">
    <path d="M110,15 L122,48 L155,48 L128,68 L138,100 L110,80 L82,100 L92,68 L65,48 L98,48 Z" fill="white" />
    <path d="M40,55 C40,90 90,95 130,50" fill="none" stroke="#F15A24" strokeWidth="12" strokeLinecap="round" />
  </svg>
);

const Sidebar: React.FC<SidebarProps> = ({ currentView, onViewChange, onViewPublicSite, onLogout, isOpen, onClose }) => {
  const menuGroups: Array<{ title: string; items: Array<{ name: ViewType; icon: React.ReactNode; color?: string; special?: boolean }> }> = [
    {
      title: "Core Mainframe",
      items: [
        { name: 'Dashboard', icon: <LayoutDashboard size={16} /> },
        { name: 'Yield Matrix', icon: <BarChart4 size={16} />, color: '#F15A24' },
        { name: 'Payouts', icon: <Banknote size={16} />, color: '#10b981' },
      ]
    },
    {
      title: "Monetization Engine",
      items: [
        { name: 'Asset Manager', icon: <Layers size={16} />, color: '#F15A24' },
        { name: 'Marketplace', icon: <Store size={16} />, color: '#3b82f6' },
        { name: 'Asset Orders', icon: <ShoppingBag size={16} />, color: '#10b981' },
        { name: 'Service Manager', icon: <Zap size={16} />, color: '#FFD700' },
      ]
    },
    {
      title: "AI & Compliance",
      items: [
        { name: 'AI Studio', icon: <Wand2 size={16} />, color: '#8B5CF6', special: true },
        { name: 'Compliance Sentinel', icon: <ShieldEllipsis size={16} />, color: '#ef4444' },
        { name: 'Policy Tracker', icon: <ShieldCheck size={16} /> },
      ]
    },
    {
      title: "Administration",
      items: [
        { name: 'Client Manager', icon: <UserCheck size={16} /> },
        { name: 'Institutional KYC', icon: <Fingerprint size={16} />, color: '#3b82f6' },
        { name: 'Staff Workflow', icon: <ClipboardList size={16} /> },
        { name: 'Finance', icon: <Wallet size={16} /> },
      ]
    },
    {
      title: "Support & Systems",
      items: [
        { name: 'Notifications', icon: <Bell size={16} />, color: '#F15A24' },
        { name: 'Client Chat', icon: <MessageSquare size={16} /> },
        { name: 'Support', icon: <LifeBuoy size={16} />, color: '#10b981' },
        { name: 'Settings', icon: <Settings size={16} /> },
      ]
    }
  ];

  const handleItemClick = (name: ViewType) => {
    onViewChange(name);
    localStorage.setItem('os_last_view', name);
    onClose();
  };

  return (
    <>
      {isOpen && (
        <div className="fixed inset-0 bg-[#020617]/90 backdrop-blur-sm z-[80] xl:hidden pointer-events-auto" onClick={onClose}></div>
      )}

      <div className={`fixed inset-y-0 left-0 w-72 bg-[#020617] text-slate-500 flex flex-col h-full border-r border-white/5 z-[100] shadow-2xl transition-transform duration-500 xl:translate-x-0 ${isOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div 
          onClick={() => handleItemClick('Dashboard')}
          className="p-8 shrink-0 flex flex-col items-center cursor-pointer group hover:opacity-80 transition-all active:scale-95"
        >
          <div className="w-14 mb-4 group-hover:scale-110 transition-transform">
            <Logo />
          </div>
          <div className="text-center w-full px-2">
            <h1 className="text-white text-base font-black tracking-tighter leading-none mb-1 truncate uppercase group-hover:text-[#F15A24] transition-colors">ONESTARS</h1>
            <p className="text-[#F15A24] text-[6px] font-black tracking-[0.5em] uppercase opacity-80">OFFICIAL ADMIN TERMINAL</p>
          </div>
        </div>
        
        <nav className="flex-1 px-4 space-y-8 overflow-y-auto custom-scrollbar pb-10">
          {menuGroups.map((group) => (
            <div key={group.title} className="space-y-2">
              <p className="px-4 text-[8px] font-black text-slate-700 uppercase tracking-[0.3em] mb-4">{group.title}</p>
              {group.items.map((item) => {
                const isActive = currentView === item.name;
                return (
                  <button
                    key={item.name}
                    onClick={() => handleItemClick(item.name)}
                    className={`w-full flex items-center gap-4 px-4 py-2.5 rounded-xl transition-all duration-300 group relative ${
                      isActive ? 'bg-white/[0.04] text-white shadow-inner border border-white/5' : 'hover:bg-white/[0.02] hover:text-slate-300'
                    }`}
                  >
                    <span className={`shrink-0 transition-colors ${isActive ? (item.color || 'text-[#F15A24]') : 'text-slate-600 group-hover:text-slate-400'}`}>
                      {item.icon}
                    </span>
                    <p className={`flex-1 text-left text-[10px] font-black uppercase tracking-widest whitespace-nowrap ${isActive ? 'text-white' : ''}`}>
                      {item.name}
                    </p>
                    {isActive && <div className="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-4 bg-[#F15A24] rounded-r-full shadow-[0_0_8px_#F15A24]"></div>}
                  </button>
                );
              })}
            </div>
          ))}
        </nav>

        <div className="p-6 space-y-3 shrink-0 border-t border-white/5 bg-black/20">
          <button onClick={onViewPublicSite} className="w-full flex items-center justify-center gap-3 py-3 rounded-xl bg-[#F15A24] text-white font-black text-[10px] uppercase tracking-widest shadow-xl hover:bg-orange-600 transition-all">
            <Globe size={14} /> Public Portal
          </button>
          <button 
            type="button"
            onClick={(e) => { e.preventDefault(); onLogout(); }} 
            className="w-full flex items-center justify-center gap-3 py-3 rounded-xl bg-white/5 text-slate-500 font-black text-[10px] uppercase tracking-widest hover:text-red-500 hover:bg-red-50/5 transition-all cursor-pointer"
          >
            <LogOut size={14} /> Global Logout
          </button>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
