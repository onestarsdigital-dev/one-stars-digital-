
export type Platform = 'Facebook' | 'YouTube' | 'TikTok' | 'Instagram' | 'Telegram' | 'Social Media' | 'Web' | 'Portal';
export type PayoutPlatform = 'facebook' | 'youtube' | 'tiktok' | 'instagram' | 'telegram' | 'social media';

export type MonetizationStatus = 'Eligible' | 'Limited' | 'Demonetized' | 'Appeal In Progress' | 'Pending Review' | 'Ineligible' | 'Payment Hold';
export type RiskLevel = 'Low' | 'Medium' | 'High' | 'Critical';
export type RiskLevelSaaS = 'Stable' | 'Watch' | 'At Risk' | 'Critical';
export type RiskStatus = 'Open' | 'Monitoring' | 'Resolved';
export type RiskCategory = 'Delay' | 'Threshold' | 'Country' | 'Bank' | 'Platform';

export interface PayoutRiskLog {
  id: string;
  client_id: string;
  client_name: string;
  platform: PayoutPlatform;
  risk_type: RiskCategory;
  risk_level: RiskLevelSaaS;
  message_client: string;
  message_internal: string;
  status: RiskStatus;
  detected_at: string;
  resolved_at?: string;
  internal_ai_score: number; // 0-100
}

export type AppealTone = 'Formal' | 'Neutral' | 'Strong' | 'Apologetic';
export type AppealOutcome = 'Submitted' | 'Pending' | 'Accepted' | 'Rejected' | 'Draft';

export interface MonetizationNode {
  id: string;
  name: string;
  platform: Platform;
  status: MonetizationStatus;
  riskLevel: RiskLevel;
  payoutRegion: string;
  lastChecked: string;
  policyReason?: string;
  internalNotes?: string;
  appealSuccessProbability?: number; // 0-100
  ownerId: string;
  ownerName: string;
  monetization_visible?: boolean;
}

export interface AppealRecord {
  id: string;
  node_id: string;
  platform: Platform;
  status: MonetizationStatus;
  violation_category: string;
  draft_text: string;
  tone: AppealTone;
  outcome: AppealOutcome;
  created_by: string;
  created_at: string;
  fixes_applied: string[];
  evidence_list: string[];
}

export interface ToolRegistryItem {
  id: string;
  key: string;
  title: string;
  icon_key: string;
  route: ViewType;
  is_active: boolean;
}

export interface ClientTool {
  id: string;
  client_id: string;
  tool_key: string;
  enabled: boolean;
  pinned: boolean;
  registry?: ToolRegistryItem;
}

export interface Profile {
  id: string;
  email: string;
  is_admin: boolean;
}

export interface RevenueRecord {
  id: string;
  date: string;
  amount: number;
  category: 'asset' | 'service' | 'academy';
  note?: string;
}

export interface ProductReview {
  id: string;
  product_id: string;
  user_id: string;
  user_name: string;
  rating: number;
  comment: string;
  created_at: string;
}

export interface PayoutAccount {
  id: string;
  client_id: string;
  platform: PayoutPlatform;
  account_name: string;
  social_link: string;
  bank_type: string;
  bank_name?: string; 
  bank_details: string;
  status: 'pending' | 'approved' | 'rejected' | 'paid' | 'restricted';
  approved_by?: string;
  approved_at?: string;
  created_at: string;
}

export interface PayoutTransaction {
  id: string;
  payout_account_id: string;
  client_id: string;
  amount: number;
  currency: string;
  payout_month: string;
  status: 'processing' | 'paid' | 'failed' | 'on_hold';
  invoice_url?: string;
  created_by: string;
  created_at: string;
}

export interface Lesson { id: string; title: string; videoUrl: string; duration: string; }

export interface DigitalProduct { 
  id: string; 
  platform: string; 
  type: string; 
  name: string; 
  description: string; 
  priceMMK: number; 
  image: string; 
  link?: string; 
  availability?: 'In Stock' | 'Out of Stock'; 
  isDraft?: boolean; 
  stats?: { views?: string };
  lessons?: Lesson[];
}

export interface ClientUser { 
  id: string; 
  name: string; 
  email: string; 
  avatar?: string; 
  enrolledCourses: string[]; 
  joinDate: string; 
  role?: string; 
  status?: string; 
  lastLogin?: string;
  telegram?: string;
  whatsapp?: string;
  phone?: string;
  country?: string;
  timezone?: string;
  niche?: string;
  bio?: string;
  website?: string;
  usdt_address?: string;
  twoFactorEnabled?: boolean;
  payout_lock_resolved?: boolean;
  bank_verified?: boolean;
  identity_verified?: boolean;
  risk_check_passed?: boolean;
  monetization_status?: string;
  monetization_visible?: boolean;
}

export type NotificationType = 'system_update' | 'admin_message' | 'security_alert';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  timestamp: string;
  isRead: boolean;
  target_user_id?: string;
}

export interface SupportTicket {
  id: string;
  subject: string;
  date: string;
  status: 'Closed' | 'Resolved' | 'Archived';
}

export type ActivityType = 'login' | 'logout' | 'profile_update' | 'security_change';

export interface ActivityLog {
  id: string;
  type: ActivityType;
  action: string;
  details: string;
  timestamp: string;
  metadata?: {
    browser?: string;
    os?: string;
    ip?: string;
  };
}

export interface Creator { id: string; name: string; platform: string; niche: string; followers: string; image: string; link: string; description: string; isFeatured?: boolean; }

export type ViewType = 
  | 'Home'
  | 'Dashboard' 
  | 'Payouts' 
  | 'Payout Risk Monitor'
  | 'Yield Matrix'
  | 'Monetization Center'
  | 'AI Appeal Assistant'
  | 'Asset Manager' 
  | 'Marketplace' 
  | 'Service Manager'
  | 'Asset Orders'
  | 'Client Manager' 
  | 'AI Studio' 
  | 'Compliance Sentinel'
  | 'Institutional KYC'
  | 'Payment Config'
  | 'Home Editor'
  | 'Staff Workflow'
  | 'Class'
  | 'Creators'
  | 'Policy Tracker'
  | 'Finance'
  | 'Client Chat'
  | 'AI Bot Settings'
  | 'Settings'
  | 'Overview'
  | 'Services'
  | 'Academy'
  | 'Tools'
  | 'Registry'
  | 'Notifications'
  | 'Support'
  | 'Activity'
  | 'Reviews';

export interface AiBotSettings {
  system_prompt: string;
  is_active: boolean;
}

export interface AdminSupportConfig {
  telegram_link: string;
  support_email: string;
  telegram_handle: string;
}

export interface HomeContent { 
  heroTitle: string; 
  heroSubtitle: string; 
  heroCtaPrimary: string; 
  heroCtaSecondary: string; 
  heroImageUrl?: string; 
  uspImageUrl?: string; 
  statsSuccessRate: string; 
  statsResponseTime: string; 
  statsTotalEarnings: string; 
  statsCourseCount: string; 
  servicesTitle: string; 
  servicesSubtitle: string; 
  ctaTitle: string; 
  ctaSubtitle: string; 
  contactPhone: string; 
  contactAddress: string; 
  agencyFacebook: string; 
  agencyYoutube: string; 
  agencyTiktok: string; 
}

export interface MonetizationService {
  id: string;
  platform: string;
  title: string;
  subtitle: string;
  icon: string;
  color: string;
  requirements: string[];
  packages: ServicePackage[];
}

export interface ServicePackage {
  id: string;
  name: string;
  description: string;
  priceMMK: number;
  features: string[];
  isPopular?: boolean;
}

export interface PaymentAccounts { kpayNumber: string; kpayName: string; waveNumber: string; waveName: string; bankName: string; bankNumber: string; bankAccountName: string; }

export interface BusinessStats { 
  totalInvestment: number;
  totalProfit: number;
  totalInvestmentMMK: number;
  totalProfitMMK: number;
  totalRevenueMMK: number;
  serviceFeeRevenue: number;
  assetRevenue: number; 
  serviceRevenue: number; 
  academyRevenue: number; 
  totalRevenue: number; 
  activeProjects: number; 
  totalClients: number; 
}

export interface ChartData { day: string; income: number; expense: number; }
export type ProjectStatus = 'Pending' | 'In Progress' | 'Completed' | 'Cancelled';
export interface Project { id: string; name: string; platform: Platform; status: ProjectStatus; price: number; startDate: string; endDate: string; clientName: string; clientLink: string; notes: string; }
export interface Message { id: string | number; session_id: string; sender_role: 'Client' | 'admin' | 'Admin' | 'client' | 'system'; sender_id?: string; text: string; metadata?: any; created_at: string; }
export interface ChatSession { id: string; client_id: string; client_name: string; client_email?: string; platform: string; unread_count: number; last_message?: string; last_message_at?: string; }
export type StaffRole = 'Video Editor' | 'Ads Specialist' | 'Customer Support' | 'Content Creator' | 'Admin';
export interface StaffTask { id: string; staffName: string; role: StaffRole; taskName: string; deadline: string; priority: 'High' | 'Medium' | 'Low'; status: string; }

export type PaymentCategory = 'Asset Sale' | 'Service Fee' | 'Academy' | 'Investment' | 'Internal';

export interface PaymentRecord {
  id: string;
  clientName: string;
  buyerName?: string;
  accountLink?: string;
  platform: Platform | 'Portal';
  serviceType: PaymentCategory;
  invoiceId: string;
  amount: { USD: number; MMK: number; THB: number };
  status: 'Paid' | 'Pending' | 'Failed';
  payoutMethod: 'KPay' | 'Wave' | 'Bank' | 'Wise' | 'Payoneer';
  payoutDate: string;
  type: 'Income' | 'Investment';
  notes?: string;
}

export interface PolicyStatus {
  id: string;
  assetName: string;
  platform: string;
  monetizationStatus: 'Enabled' | 'Warning' | 'Restricted' | 'Disabled' | string;
  strikeCount: number;
  warnings: string[];
  appealStatus: string;
  lastChecked: string;
  riskMitigationPlan?: string;
}
