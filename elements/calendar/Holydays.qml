pragma Singleton

import Quickshell

Singleton {
  readonly property var lunar: ({
    "1/1": { isSpecial: true, name: "Nguyên đán" },
    "2/1": { isSpecial: true, },
    "3/1": { isSpecial: true, },
    "15/1": { name: "Nguyên Tiêu" },
    "3/3": { name: "Hàn thực" },
    "10/3": { isSpecial: true, name: "Giỗ tổ" },
    "15/4": { name: "Phật Đản" },
    "5/5": { name: "Đoan ngọ" },
    "7/7": { name: "Thất tịch" },
    "15/7": { name: "Vu Lan" },
    "15/8": { name: "Trung thu" },
    "9/9": { name: "Trùng cửu" },
    "10/10": { name: "Trùng thập" },
    "15/10": { name: "Hạ Nguyên" },
    "23/12": { name: "Ông táo" },
  })
  readonly property var solar: ({
    "1/1": { isSpecial: true, name: "Tết Dương" },
    "9/1": { name: "HSSV", startYear: 1950 },
    "3/2": { name: "Đảng CSVN", startYear: 1930 },
    "14/2": { name: "Valentine" },
    "27/2": { name: "Thầy thuốc", startYear: 1955 },
    "8/3": { name: "Phụ nữ" },
    "20/3": { name: "Hạnh phúc" },
    "26/3": { name: "Đoàn TNCS", startYear: 1931 },
    "1/4": { name: "Cá tháng Tư" },
    "30/4": { isSpecial: true, name: "Giải phóng", startYear: 1975 },
    "1/5": { isSpecial: true, name: "Lao động" },
    "7/5": { name: "ĐBP", startYear: 1954 },
    // 13/5 Mother's day dynamic
    "15/5": { name: "Đội TNTP", startYear: 1941 },
    "19/5": { name: "SN Bác", startYear: 1890 },
    "1/6": { name: "Thiếu nhi" },
    // 17/6 Father's day dynamic
    "21/6": { name: "Báo chí", startYear: 1925 },
    "28/6": { name: "Gia đình", startYear: 2001 },
    "11/7": { name: "Dân số" },
    "27/7": { name: "TBLS", startYear: 1947 },
    "28/7": { name: "Công đoàn", startYear: 1929 },
    "19/8": { isSpecial: true, name: "CMT8", startYear: 1945 },
    "2/9": { isSpecial: true, name: "Quốc Khánh", startYear: 1945 },
    "10/9": { name: "MTTQVN", startYear: 1955 },
    "1/10": { name: "Cao tuổi" },
    "10/10": { name: "Thủ đô", startYear: 1954 },
    "13/10": { name: "Doanh nhân", startYear: 2004 },
    "20/10": { name: "Phụ nữ", startYear: 1930 },
    "31/10": { name: "Halloween" },
    "9/11": { name: "Pháp luật", startYear: 2013 },
    "19/11": { name: "Nam giới" },
    "20/11": { name: "Nhà giáo", startYear: 1982 },
    "23/11": { name: "Chữ thập đỏ", startYear: 1946 },
    "24/11": { isSpecial: true, name: "Văn hoá VN", startYear: 2026 },
    "1/12": { name: "AIDS" },
    "19/12": { name: "Kháng chiến", startYear: 1946 },
    "24/12": { name: "Giáng sinh" },
    "22/12": { name: "QĐNDVN", startYear: 1944 },
  })
}