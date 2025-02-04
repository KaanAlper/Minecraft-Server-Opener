#!/bin/bash

# Bağımlılık Kontrolleri

check_dependencies() {
    local missing=()
    for cmd in fzf curl; do
        if ! command -v $cmd &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Eksik bağımlılıklar: ${missing[*]}"
        read -p "Yüklemek ister misiniz? (E/h) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ee]$ ]]; then
            sudo apt update
            sudo apt install -y "${missing[@]}"
        else
            exit 1
        fi
    fi
}
check_dependencies

current_dir="$(pwd)"

# Türkçe karakter kontrolü (ü, Ü, İ, ı, ö, Ö, ğ, Ğ, ç, Ç, ş, Ş)
if [[ "$current_dir" =~ [üÜİıöÖğĞçÇşŞ] ]]; then
    echo "❌ Hata: Betik '$current_dir' dizininde çalıştırılıyor (Forge vb hata verebilir)."
    echo "⚠️  Bu dizin adında Türkçe karakterler (ü, Ü, İ, ı, ö, Ö, ğ, Ğ, ç, Ç, ş, Ş) var."
    echo "✅ Lütfen betiği Türkçe karakter içermeyen bir dizinde çalıştırın."

    # fzf ile kullanıcıya seçim sun
    choice=$(printf "Devam Et\nİptal Et" | fzf --prompt="❓ Ne yapmak istersiniz? " --height=10 --border --reverse)

    # Kullanıcının seçimine göre işlem yap
    if [[ "$choice" != "Devam Et" ]]; then
        echo "🚫 İşlem iptal edildi."
        exit 1  # Betiği durdur
    fi
fi

# Betik burada çalışmaya devam eder
echo "✅ Dizin uygun veya kullanıcı onay verdi, betik çalışıyor."

JAVA_8="/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/java"
JAVA_17="/usr/lib/jvm/java-1.17.0-openjdk-amd64/bin/java"
JAVA_21="/usr/lib/jvm/java-1.21.0-openjdk-amd64/bin/java"

declare -A SERVER_URLS=(
    ["Vanilla"]="DIRECT"
    ["Forge"]="DIRECT"
    ["Paper"]="DIRECT"
    ["Fabric"]="DIRECT"
    ["Sponge"]="DIRECT"
)

    
# Java yükleme fonksiyonu
install_java() {
    local version=$1
    local package=$2
    read -p "$version yüklü değil. Yüklemek ister misin? (E/h): " choice
    if [[ "$choice" =~ ^[Ee]$ ]]; then
        sudo apt update
        sudo apt install -y "$package"
        echo "$version başarıyla yüklendi."
    else
        echo "$version yüklenmedi, işlem iptal edildi."
        exit 1
    fi
}

# Java mevcut değilse yükleme işlemi
[[ ! -f "$JAVA_8" ]] && install_java "Java 8" "openjdk-8-jre"
[[ ! -f "$JAVA_17" ]] && install_java "Java 17" "openjdk-17-jre"
[[ ! -f "$JAVA_21" ]] && install_java "Java 21" "openjdk-21-jre"


# Vanilla versiyon listesi
declare -A VANILLA_VERSIONS=(
    ["1.21.4"]="https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar"
    ["1.21.3"]="https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar"
    ["1.21.2"]="https://piston-data.mojang.com/v1/objects/7bf95409b0d9b5388bfea3704ec92012d273c14c/server.jar"
    ["1.21.1"]="https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar"
    ["1.21"]="https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar"
    ["1.20.6"]="https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar"
    ["1.20.5"]="https://piston-data.mojang.com/v1/objects/79493072f65e17243fd36a699c9a96b4381feb91/server.jar"
    ["1.20.4"]="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
    ["1.20.3"]="https://piston-data.mojang.com/v1/objects/4fb536bfd4a83d61cdbaf684b8d311e66e7d4c49/server.jar"
    ["1.20.2"]="https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
    ["1.20.1"]="https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar"
    ["1.20"]="https://piston-data.mojang.com/v1/objects/15c777e2cfe0556eef19aab534b186c0c6f277e1/server.jar"
    ["1.19.4"]="https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar"
    ["1.19.3"]="https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar"
    ["1.19.2"]="https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar"
    ["1.19.1"]="https://piston-data.mojang.com/v1/objects/8399e1211e95faa421c1507b322dbeae86d604df/server.jar"
    ["1.19"]="https://piston-data.mojang.com/v1/objects/e00c4052dac1d59a1188b2aa9d5a87113aaf1122/server.jar"
    ["1.18.2"]="https://piston-data.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar"
    ["1.18.1"]="https://piston-data.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar"
    ["1.18"]="https://piston-data.mojang.com/v1/objects/3cf24a8694aca6267883b17d934efacc5e44440d/server.jar"
    ["1.17.1"]="https://piston-data.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar"
    ["1.17"]="https://piston-data.mojang.com/v1/objects/0a269b5f2c5b93b1712d0f5dc43b6182b9ab254e/server.jar"
    ["1.16.5"]="https://piston-data.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"
    ["1.16.4"]="https://piston-data.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar"
    ["1.16.3"]="https://piston-data.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar"
    ["1.16.2"]="https://piston-data.mojang.com/v1/objects/c5f6fb23c3876461d46ec380421e42b289789530/server.jar"
    ["1.16.1"]="https://piston-data.mojang.com/v1/objects/a412fd69db1f81db3f511c1463fd304675244077/server.jar"
    ["1.16"]="https://piston-data.mojang.com/v1/objects/a0d03225615ba897619220e256a266cb33a44b6b/server.jar"
    ["1.15.2"]="https://piston-data.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar"
    ["1.15.1"]="https://piston-data.mojang.com/v1/objects/4d1826eebac84847c71a77f9349cc22afd0cf0a1/server.jar"
    ["1.15"]="https://piston-data.mojang.com/v1/objects/e9f105b3c5c7e85c7b445249a93362a22f62442d/server.jar"
    ["1.14.4"]="https://piston-data.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar"
    ["1.14.3"]="https://piston-data.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar"
    ["1.14.2"]="https://piston-data.mojang.com/v1/objects/808be3869e2ca6b62378f9f4b33c946621620019/server.jar"
    ["1.14.1"]="https://piston-data.mojang.com/v1/objects/ed76d597a44c5266be2a7fcd77a8270f1f0bc118/server.jar"
    ["1.14"]="https://piston-data.mojang.com/v1/objects/f1a0073671057f01aa843443fef34330281333ce/server.jar"
    ["1.13.2"]="https://piston-data.mojang.com/v1/objects/3737db93722a9e39eeada7c27e7aca28b144ffa7/server.jar"
    ["1.13.1"]="https://piston-data.mojang.com/v1/objects/fe123682e9cb30031eae351764f653500b7396c9/server.jar"
    ["1.13"]="https://piston-data.mojang.com/v1/objects/d0caafb8438ebd206f99930cfaecfa6c9a13dca0/server.jar"
    ["1.12.2"]="https://piston-data.mojang.com/v1/objects/886945bfb2b978778c3a0288fd7fab09d315b25f/server.jar"
    ["1.12.1"]="https://piston-data.mojang.com/v1/objects/561c7b2d54bae80cc06b05d950633a9ac95da816/server.jar"
    ["1.12"]="https://piston-data.mojang.com/v1/objects/8494e844e911ea0d63878f64da9dcc21f53a3463/server.jar"
    ["1.11.2"]="https://piston-data.mojang.com/v1/objects/f00c294a1576e03fddcac777c3cf4c7d404c4ba4/server.jar"
    ["1.11.1"]="https://piston-data.mojang.com/v1/objects/1f97bd101e508d7b52b3d6a7879223b000b5eba0/server.jar"
    ["1.11"]="https://piston-data.mojang.com/v1/objects/48820c84cb1ed502cb5b2fe23b8153d5e4fa61c0/server.jar"
    ["1.10.2"]="https://piston-data.mojang.com/v1/objects/3d501b23df53c548254f5e3f66492d178a48db63/server.jar"
    ["1.10.1"]="https://piston-data.mojang.com/v1/objects/cb4c6f9f51a845b09a8861cdbe0eea3ff6996dee/server.jar"
    ["1.10"]="https://piston-data.mojang.com/v1/objects/a96617ffdf5dabbb718ab11a9a68e50545fc5bee/server.jar"
    ["1.9.4"]="https://piston-data.mojang.com/v1/objects/edbb7b1758af33d365bf835eb9d13de005b1e274/server.jar"
    ["1.9.3"]="https://piston-data.mojang.com/v1/objects/8e897b6b6d784f745332644f4d104f7a6e737ccf/server.jar"
    ["1.9.2"]="https://piston-data.mojang.com/v1/objects/2b95cc7b136017e064c46d04a5825fe4cfa1be30/server.jar"
    ["1.9.1"]="https://piston-data.mojang.com/v1/objects/bf95d9118d9b4b827f524c878efd275125b56181/server.jar"
    ["1.9"]="https://piston-data.mojang.com/v1/objects/b4d449cf2918e0f3bd8aa18954b916a4d1880f0d/server.jar"
    ["1.8.9"]="https://launcher.mojang.com/v1/objects/b58b2ceb36e01bcd8dbf49c8fb66c55a9f0676cd/server.jar"
    ["1.8.8"]="https://launcher.mojang.com/v1/objects/5fafba3f58c40dc51b5c3ca72a98f62dfdae1db7/server.jar"
    ["1.8.7"]="https://launcher.mojang.com/v1/objects/35c59e16d1f3b751cd20b76b9b8a19045de363a9/server.jar"
    ["1.8.6"]="https://launcher.mojang.com/v1/objects/2bd44b53198f143fb278f8bec3a505dad0beacd2/server.jar"
    ["1.8.5"]="https://launcher.mojang.com/v1/objects/ea6dd23658b167dbc0877015d1072cac21ab6eee/server.jar"
    ["1.8.4"]="https://launcher.mojang.com/v1/objects/dd4b5eba1c79500390e0b0f45162fa70d38f8a3d/server.jar"
    ["1.8.3"]="https://launcher.mojang.com/v1/objects/163ba351cb86f6390450bb2a67fafeb92b6c0f2f/server.jar"
    ["1.8.2"]="https://launcher.mojang.com/v1/objects/a37bdd5210137354ed1bfe3dac0a5b77fe08fe2e/server.jar"
    ["1.8.1"]="https://launcher.mojang.com/v1/objects/68bfb524888f7c0ab939025e07e5de08843dac0f/server.jar"
    ["1.8"]="https://launcher.mojang.com/v1/objects/a028f00e678ee5c6aef0e29656dca091b5df11c7/server.jar"
    ["1.7.10"]="https://launcher.mojang.com/v1/objects/952438ac4e01b4d115c5fc38f891710c4941df29/server.jar"
    ["1.7.9"]="https://launcher.mojang.com/v1/objects/4cec86a928ec171fdc0c6b40de2de102f21601b5/server.jar"
    ["1.7.8"]="https://launcher.mojang.com/v1/objects/c69ebfb84c2577661770371c4accdd5f87b8b21d/server.jar"
    ["1.7.7"]="https://launcher.mojang.com/v1/objects/a6ffc1624da980986c6cc12a1ddc79ab1b025c62/server.jar"
    ["1.7.6"]="https://launcher.mojang.com/v1/objects/41ea7757d4d7f74b95fc1ac20f919a8e521e910c/server.jar"
    ["1.7.5"]="https://launcher.mojang.com/v1/objects/e1d557b2e31ea881404e41b05ec15c810415e060/server.jar"
    ["1.7.4"]="https://launcher.mojang.com/v1/objects/61220311cef80aecc4cd8afecd5f18ca6b9461ff/server.jar"
    ["1.7.3"]="https://launcher.mojang.com/v1/objects/707857a7bc7bf54fe60d557cca71004c34aa07bb/server.jar"
    ["1.7.2"]="https://launcher.mojang.com/v1/objects/3716cac82982e7c2eb09f83028b555e9ea606002/server.jar"
    ["1.6.4"]="https://launcher.mojang.com/v1/objects/050f93c1f3fe9e2052398f7bd6aca10c63d64a87/server.jar"
    ["1.6.2"]="https://launcher.mojang.com/v1/objects/01b6ea555c6978e6713e2a2dfd7fe19b1449ca54/server.jar"
    ["1.6.1"]="https://launcher.mojang.com/v1/objects/0252918a5f9d47e3c6eb1dfec02134d1374a89b4/server.jar"
    ["1.5.2"]="https://launcher.mojang.com/v1/objects/f9ae3f651319151ce99a0bfad6b34fa16eb6775f/server.jar"
    ["1.5.1"]="https://launcher.mojang.com/v1/objects/d07c71ee2767dabb79fb32dad8162e1b854d5324/server.jar"
    ["1.4.7"]="https://launcher.mojang.com/v1/objects/2f0ec8efddd2f2c674c77be9ddb370b727dec676/server.jar"
    ["1.4.6"]="https://launcher.mojang.com/v1/objects/a0aeb5709af5f2c3058c1cf0dc6b110a7a61278c/server.jar"
    ["1.4.5"]="https://launcher.mojang.com/v1/objects/c12fd88a8233d2c517dbc8196ba2ae855f4d36ea/server.jar"
    ["1.4.4"]="https://launcher.mojang.com/v1/objects/4215dcadb706508bf9d6d64209a0080b9cee9e71/server.jar"
    ["1.4.2"]="https://launcher.mojang.com/v1/objects/5be700523a729bb78ef99206fb480a63dcd09825/server.jar"
    ["1.3.2"]="https://launcher.mojang.com/v1/objects/3de2ae6c488135596e073a9589842800c9f53bfe/server.jar"
    ["1.3.1"]="https://launcher.mojang.com/v1/objects/82563ce498bfc1fc8a2cb5bf236f7da86a390646/server.jar"
    ["1.2.5"]="https://launcher.mojang.com/v1/objects/d8321edc9470e56b8ad5c67bbd16beba25843336/server.jar"
)
declare -A SPONGE_VERSIONS=(
    ["1.21.4"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.21.4-14.0.0-RC2028/spongevanilla-1.21.4-14.0.0-RC2028-universal.jar"
    ["1.21.3"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.21.3-13.0.1-RC2027/spongevanilla-1.21.3-13.0.1-RC2027-universal.jar"
    ["1.20.6"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.20.6-11.0.1-RC1916/spongevanilla-1.20.6-11.0.1-RC1916-universal.jar"
    ["1.20.4"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.20.4-11.0.0-RC1589/spongevanilla-1.20.4-11.0.0-RC1589-universal.jar"
    ["1.20.2"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.20.2-11.0.0-RC1478/spongevanilla-1.20.2-11.0.0-RC1478-universal.jar"
    ["1.20.1"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.20.1-11.0.0-RC1365/spongevanilla-1.20.1-11.0.0-RC1365-universal.jar"
    ["1.19.4"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.19.4-10.0.0-RC1588/spongevanilla-1.19.4-10.0.0-RC1588-universal.jar"
    ["1.19.3"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.19.3-10.0.0-RC1277/spongevanilla-1.19.3-10.0.0-RC1277-universal.jar"
    ["1.19.2"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.19.2-10.0.0-RC1239/spongevanilla-1.19.2-10.0.0-RC1239-universal.jar"
    ["1.18.2"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.18.2-9.0.0-RC1306/spongevanilla-1.18.2-9.0.0-RC1306-universal.jar"
    ["1.18.1"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.18.1-9.0.0-RC1119/spongevanilla-1.18.1-9.0.0-RC1119-universal.jar"
    ["1.17.1"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.17.1-9.0.0-RC977/spongevanilla-1.17.1-9.0.0-RC977-universal.jar"
    ["1.16.5"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.16.5-8.2.1-RC1737/spongevanilla-1.16.5-8.2.1-RC1737-universal.jar"
    ["1.16.4"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.16.4-8.0.0-RC390/spongevanilla-1.16.4-8.0.0-RC390-universal.jar"
    ["1.15.2"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.15.2-8.0.0-SNAPSHOT/spongevanilla-1.15.2-8.0.0-SNAPSHOT-universal.jar"
    ["1.12.2"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.12.2-8.0.0-BETA-448/spongevanilla-1.12.2-8.0.0-BETA-448-universal.jar"
    ["1.12.1"]="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/1.12.1-7.0.0-BETA-329/spongevanilla-1.12.1-7.0.0-BETA-329-universal.jar"
    ["1.11.2"]="https://repo.spongepowered.org/repository/legacy-transfer/org/spongepowered/spongevanilla/1.11.2-7.0.0-BETA-275/spongevanilla-1.11.2-7.0.0-BETA-275.jar"
    ["1.10.2"]="https://repo.spongepowered.org/repository/legacy-transfer/org/spongepowered/spongevanilla/1.10.2-6.0.0-BETA-161/spongevanilla-1.10.2-6.0.0-BETA-161.jar"
    ["1.9.4"]="https://repo.spongepowered.org/repository/legacy-transfer/org/spongepowered/spongevanilla/1.9.4-5.0.0-BETA-83/spongevanilla-1.9.4-5.0.0-BETA-83.jar"
    ["1.8.9"]="https://repo.spongepowered.org/repository/legacy-transfer/org/spongepowered/spongevanilla/1.8.9-4.2.0-BETA-352/spongevanilla-1.8.9-4.2.0-BETA-352.jar"
)

declare -A PAPER_VERSIONS=(
    ["1.8.8"]="https://api.papermc.io/v2/projects/paper/versions/1.8.8/builds/445/downloads/paper-1.8.8-445.jar"
    ["1.9.4"]="https://api.papermc.io/v2/projects/paper/versions/1.9.4/builds/775/downloads/paper-1.9.4-775.jar"
    ["1.10.2"]="https://api.papermc.io/v2/projects/paper/versions/1.10.2/builds/918/downloads/paper-1.10.2-918.jar"
    ["1.11.2"]="https://api.papermc.io/v2/projects/paper/versions/1.11.2/builds/1106/downloads/paper-1.11.2-1106.jar"
    ["1.12"]="https://api.papermc.io/v2/projects/paper/versions/1.12/builds/1169/downloads/paper-1.12-1169.jar"
    ["1.12.1"]="https://api.papermc.io/v2/projects/paper/versions/1.12.1/builds/1204/downloads/paper-1.12.1-1204.jar"
    ["1.12.2"]="https://api.papermc.io/v2/projects/paper/versions/1.12.2/builds/1620/downloads/paper-1.12.2-1620.jar"
    ["1.13-pre7"]="https://api.papermc.io/v2/projects/paper/versions/1.13-pre7/builds/12/downloads/paper-1.13-pre7-12.jar"
    ["1.13"]="https://api.papermc.io/v2/projects/paper/versions/1.13/builds/173/downloads/paper-1.13-173.jar"
    ["1.13.1"]="https://api.papermc.io/v2/projects/paper/versions/1.13.1/builds/386/downloads/paper-1.13.1-386.jar"
    ["1.13.2"]="https://api.papermc.io/v2/projects/paper/versions/1.13.2/builds/657/downloads/paper-1.13.2-657.jar"
    ["1.14"]="https://api.papermc.io/v2/projects/paper/versions/1.14/builds/17/downloads/paper-1.14-17.jar"
    ["1.14.1"]="https://api.papermc.io/v2/projects/paper/versions/1.14.1/builds/50/downloads/paper-1.14.1-50.jar"
    ["1.14.2"]="https://api.papermc.io/v2/projects/paper/versions/1.14.2/builds/107/downloads/paper-1.14.2-107.jar"
    ["1.14.3"]="https://api.papermc.io/v2/projects/paper/versions/1.14.3/builds/134/downloads/paper-1.14.3-134.jar"
    ["1.14.4"]="https://api.papermc.io/v2/projects/paper/versions/1.14.4/builds/245/downloads/paper-1.14.4-245.jar"
    ["1.15"]="https://api.papermc.io/v2/projects/paper/versions/1.15/builds/21/downloads/paper-1.15-21.jar"
    ["1.15.1"]="https://api.papermc.io/v2/projects/paper/versions/1.15.1/builds/62/downloads/paper-1.15.1-62.jar"
    ["1.15.2"]="https://api.papermc.io/v2/projects/paper/versions/1.15.2/builds/393/downloads/paper-1.15.2-393.jar"
    ["1.16.1"]="https://api.papermc.io/v2/projects/paper/versions/1.16.1/builds/138/downloads/paper-1.16.1-138.jar"
    ["1.16.2"]="https://api.papermc.io/v2/projects/paper/versions/1.16.2/builds/189/downloads/paper-1.16.2-189.jar"
    ["1.16.3"]="https://api.papermc.io/v2/projects/paper/versions/1.16.3/builds/253/downloads/paper-1.16.3-253.jar"
    ["1.16.4"]="https://api.papermc.io/v2/projects/paper/versions/1.16.4/builds/416/downloads/paper-1.16.4-416.jar"
    ["1.16.5"]="https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar"
    ["1.17"]="https://api.papermc.io/v2/projects/paper/versions/1.17/builds/79/downloads/paper-1.17-79.jar"
    ["1.17.1"]="https://api.papermc.io/v2/projects/paper/versions/1.17.1/builds/411/downloads/paper-1.17.1-411.jar"
    ["1.18"]="https://api.papermc.io/v2/projects/paper/versions/1.18/builds/66/downloads/paper-1.18-66.jar"
    ["1.18.1"]="https://api.papermc.io/v2/projects/paper/versions/1.18.1/builds/216/downloads/paper-1.18.1-216.jar"
    ["1.18.2"]="https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/388/downloads/paper-1.18.2-388.jar"
    ["1.19"]="https://api.papermc.io/v2/projects/paper/versions/1.19/builds/81/downloads/paper-1.19-81.jar"
    ["1.19.1"]="https://api.papermc.io/v2/projects/paper/versions/1.19.1/builds/111/downloads/paper-1.19.1-111.jar"
    ["1.19.2"]="https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/307/downloads/paper-1.19.2-307.jar"
    ["1.19.3"]="https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/448/downloads/paper-1.19.3-448.jar"
    ["1.19.4"]="https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/550/downloads/paper-1.19.4-550.jar"
    ["1.20"]="https://api.papermc.io/v2/projects/paper/versions/1.20/builds/17/downloads/paper-1.20-17.jar"
    ["1.20.1"]="https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/196/downloads/paper-1.20.1-196.jar"
    ["1.20.2"]="https://api.papermc.io/v2/projects/paper/versions/1.20.2/builds/318/downloads/paper-1.20.2-318.jar"
    ["1.20.4"]="https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/499/downloads/paper-1.20.4-499.jar"
    ["1.20.5"]="https://api.papermc.io/v2/projects/paper/versions/1.20.5/builds/22/downloads/paper-1.20.5-22.jar"
    ["1.20.6"]="https://api.papermc.io/v2/projects/paper/versions/1.20.6/builds/151/downloads/paper-1.20.6-151.jar"
    ["1.21"]="https://api.papermc.io/v2/projects/paper/versions/1.21/builds/130/downloads/paper-1.21-130.jar"
    ["1.21.1"]="https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/132/downloads/paper-1.21.1-132.jar"
    ["1.21.3"]="https://api.papermc.io/v2/projects/paper/versions/1.21.3/builds/82/downloads/paper-1.21.3-82.jar"
    ["1.21.4"]="https://api.papermc.io/v2/projects/paper/versions/1.21.4/builds/136/downloads/paper-1.21.4-136.jar"
)

declare -A FABRIC_VERSIONS=(
    ["1.21.4"]="https://meta.fabricmc.net/v2/versions/loader/1.21.4/0.16.10//1.0.1/server/jar"
    ["1.21.3"]="https://meta.fabricmc.net/v2/versions/loader/1.21.3/0.16.10//1.0.1/server/jar"
    ["1.21.2"]="https://meta.fabricmc.net/v2/versions/loader/1.21.2/0.16.10//1.0.1/server/jar"
    ["1.21.1"]="https://meta.fabricmc.net/v2/versions/loader/1.21.1/0.16.10//1.0.1/server/jar"
    ["1.21"]="https://meta.fabricmc.net/v2/versions/loader/1.21/0.16.10//1.0.1/server/jar"
    ["1.20.6"]="https://meta.fabricmc.net/v2/versions/loader/1.20.6/0.16.10//1.0.1/server/jar"
    ["1.20.5"]="https://meta.fabricmc.net/v2/versions/loader/1.20.5/0.16.10//1.0.1/server/jar"
    ["1.20.4"]="https://meta.fabricmc.net/v2/versions/loader/1.20.4/0.16.10//1.0.1/server/jar"
    ["1.20.3"]="https://meta.fabricmc.net/v2/versions/loader/1.20.3/0.16.10//1.0.1/server/jar"
    ["1.20.2"]="https://meta.fabricmc.net/v2/versions/loader/1.20.2/0.16.10//1.0.1/server/jar"
    ["1.20.1"]="https://meta.fabricmc.net/v2/versions/loader/1.20.1/0.16.10//1.0.1/server/jar"
    ["1.20"]="https://meta.fabricmc.net/v2/versions/loader/1.20/0.16.10//1.0.1/server/jar"
    ["1.19.4"]="https://meta.fabricmc.net/v2/versions/loader/1.19.4/0.16.10//1.0.1/server/jar"
    ["1.19.3"]="https://meta.fabricmc.net/v2/versions/loader/1.19.3/0.16.10//1.0.1/server/jar"
    ["1.19.2"]="https://meta.fabricmc.net/v2/versions/loader/1.19.2/0.16.10//1.0.1/server/jar"
    ["1.19.1"]="https://meta.fabricmc.net/v2/versions/loader/1.19.1/0.16.10//1.0.1/server/jar"
    ["1.19"]="https://meta.fabricmc.net/v2/versions/loader/1.19/0.16.10//1.0.1/server/jar"
    ["1.18.2"]="https://meta.fabricmc.net/v2/versions/loader/1.18.2/0.16.10//1.0.1/server/jar"
    ["1.18.1"]="https://meta.fabricmc.net/v2/versions/loader/1.18.1/0.16.10//1.0.1/server/jar"
    ["1.18"]="https://meta.fabricmc.net/v2/versions/loader/1.18/0.16.10//1.0.1/server/jar"
    ["1.17.1"]="https://meta.fabricmc.net/v2/versions/loader/1.17.1/0.16.10//1.0.1/server/jar"
    ["1.17"]="https://meta.fabricmc.net/v2/versions/loader/1.17/0.16.10//1.0.1/server/jar"
    ["1.16.5"]="https://meta.fabricmc.net/v2/versions/loader/1.16.5/0.16.10//1.0.1/server/jar"
    ["1.16.4"]="https://meta.fabricmc.net/v2/versions/loader/1.16.4/0.16.10//1.0.1/server/jar"
    ["1.16.3"]="https://meta.fabricmc.net/v2/versions/loader/1.16.3/0.16.10//1.0.1/server/jar"
    ["1.16.2"]="https://meta.fabricmc.net/v2/versions/loader/1.16.2/0.16.10//1.0.1/server/jar"
    ["1.16.1"]="https://meta.fabricmc.net/v2/versions/loader/1.16.1/0.16.10//1.0.1/server/jar"
    ["1.16"]="https://meta.fabricmc.net/v2/versions/loader/1.16/0.16.10//1.0.1/server/jar"
    ["1.15.2"]="https://meta.fabricmc.net/v2/versions/loader/1.15.2/0.16.10//1.0.1/server/jar"
    ["1.15.1"]="https://meta.fabricmc.net/v2/versions/loader/1.15.1/0.16.10//1.0.1/server/jar"
    ["1.15"]="https://meta.fabricmc.net/v2/versions/loader/1.15/0.16.10//1.0.1/server/jar"
    ["1.14.4"]="https://meta.fabricmc.net/v2/versions/loader/1.14.4/0.16.10//1.0.1/server/jar"
    ["1.14.3"]="https://meta.fabricmc.net/v2/versions/loader/1.14.3/0.16.10//1.0.1/server/jar"
    ["1.14.2"]="https://meta.fabricmc.net/v2/versions/loader/1.14.2/0.16.10//1.0.1/server/jar"
    ["1.14.1"]="https://meta.fabricmc.net/v2/versions/loader/1.14.1/0.16.10//1.0.1/server/jar"
    ["1.14"]="https://meta.fabricmc.net/v2/versions/loader/1.14/0.16.10//1.0.1/server/jar"
)

declare -A FORGE_VERSIONS=(
    ["1.21.3"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.21.3-53.0.44/forge-1.21.3-53.0.44-installer.jar"
    ["1.21.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.21.1-52.0.47/forge-1.21.1-52.0.47-installer.jar"
    ["1.21"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.21-51.0.33/forge-1.21-51.0.33-installer.jar"
    ["1.20.6"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.6-50.1.39/forge-1.20.6-50.1.39-installer.jar"
    ["1.20.4"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.4-49.1.29/forge-1.20.4-49.1.29-installer.jar"
    ["1.20.3"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.3-49.0.2/forge-1.20.3-49.0.2-installer.jar"
    ["1.20.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.2-48.1.0/forge-1.20.2-48.1.0-installer.jar"
    ["1.20.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.27/forge-1.20.1-47.3.27-installer.jar"
    ["1.20"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20-46.0.14/forge-1.20-46.0.14-installer.jar"
    ["1.19.4"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.3.20/forge-1.19.4-45.3.20-installer.jar"
    ["1.19.3"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.3-44.1.23/forge-1.19.3-44.1.23-installer.jar"
    ["1.19.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.2-43.4.16/forge-1.19.2-43.4.16-installer.jar"
    ["1.19.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.1-42.0.9/forge-1.19.1-42.0.9-installer.jar"
    ["1.19"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19-41.1.0/forge-1.19-41.1.0-installer.jar"
    ["1.18.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.3.3/forge-1.18.2-40.3.3-installer.jar"
    ["1.18.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.1-39.1.2/forge-1.18.1-39.1.2-installer.jar"
    ["1.18"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.18-38.0.17/forge-1.18-38.0.17-installer.jar"
    ["1.17.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.17.1-37.1.1/forge-1.17.1-37.1.1-installer.jar"
    ["1.16.5"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.42/forge-1.16.5-36.2.42-installer.jar"
    ["1.16.4"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.4-35.1.37/forge-1.16.4-35.1.37-installer.jar"
    ["1.16.3"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.3-34.1.42/forge-1.16.3-34.1.42-installer.jar"
    ["1.16.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.2-33.0.61/forge-1.16.2-33.0.61-installer.jar"
    ["1.16.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.1-32.0.108/forge-1.16.1-32.0.108-installer.jar"
    ["1.15.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.15.2-31.2.57/forge-1.15.2-31.2.57-installer.jar"
    ["1.15.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.15.1-30.0.51/forge-1.15.1-30.0.51-installer.jar"
    ["1.15"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.15-29.0.4/forge-1.15-29.0.4-installer.jar"
    ["1.14.4"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.14.4-28.2.26/forge-1.14.4-28.2.26-installer.jar"
    ["1.14.3"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.14.3-27.0.60/forge-1.14.3-27.0.60-installer.jar"
    ["1.14.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.14.2-26.0.63/forge-1.14.2-26.0.63-installer.jar"
    ["1.13.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.13.2-25.0.223/forge-1.13.2-25.0.223-installer.jar"
    ["1.12.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar"
    ["1.12.1"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.1-14.22.1.2485/forge-1.12.1-14.22.1.2485-installer.jar"
    ["1.12"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.12-14.21.1.2443/forge-1.12-14.21.1.2443-installer.jar"
    ["1.11.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.11.2-13.20.1.2588/forge-1.11.2-13.20.1.2588-installer.jar"
    ["1.11"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.11-13.19.1.2199/forge-1.11-13.19.1.2199-installer.jar"
    ["1.10.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.10.2-12.18.3.2511/forge-1.10.2-12.18.3.2511-installer.jar"
    ["1.10"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.10-12.18.0.2000-1.10.0/forge-1.10-12.18.0.2000-1.10.0-installer.jar"
    ["1.9.4"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.9.4-12.17.0.2317-1.9.4/forge-1.9.4-12.17.0.2317-1.9.4-installer.jar"
    ["1.9"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.9-12.16.1.1938-1.9.0/forge-1.9-12.16.1.1938-1.9.0-installer.jar"
    ["1.8.9"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.8.9-11.15.1.2318-1.8.9/forge-1.8.9-11.15.1.2318-1.8.9-installer.jar"
    ["1.8.8"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.8.8-11.15.0.1655/forge-1.8.8-11.15.0.1655-installer.jar"
    ["1.8"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.8-11.14.4.1577/forge-1.8-11.14.4.1577-installer.jar"
    ["1.7.10"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.7.10-10.13.4.1614-1.7.10/forge-1.7.10-10.13.4.1614-1.7.10-installer.jar"
    ["1.6.4"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.6.4-9.11.1.1345/forge-1.6.4-9.11.1.1345-installer.jar"
    ["1.6.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.6.2-9.10.1.872/forge-1.6.2-9.10.1.872-installer.jar"
    ["1.5.2"]="https://maven.minecraftforge.net/net/minecraftforge/forge/1.5.2-7.8.1.737/forge-1.5.2-7.8.1.737-installer.jar"
)


# Sürüm formatlama fonksiyonu
get_major_version() {
    echo "$1" | cut -d. -f1-2
}

select_version() {
    local server_type=$1
    local versions
    local major_versions
    local selected_major

    case "$server_type" in
        "Vanilla") versions_array=("${!VANILLA_VERSIONS[@]}") ;;
        "Forge") versions_array=("${!FORGE_VERSIONS[@]}") ;;
        "Fabric") versions_array=("${!FABRIC_VERSIONS[@]}") ;;
        "Paper") versions_array=("${!PAPER_VERSIONS[@]}") ;;
        "Sponge") versions_array=("${!SPONGE_VERSIONS[@]}") ;;
        *) echo "Bilinmeyen sunucu türü: $server_type"; return 1 ;;
    esac
	all_versions=$(printf "%s\n" "${versions_array[@]}")

	# Major versiyonları bul
	major_versions=""
	for v in "${versions_array[@]}"; do
		major_versions+="$(get_major_version "$v").x\n"
	done

	# Geri seçeneğini ekleyelim
	major_versions="<<< Geri\n$major_versions"

	# Major versiyonları sırala ve uniq yap
	major_versions=$(echo -e "$major_versions" | sort -Vru | uniq)


		# Major sürüm seçimi
	while true; do
		while true; do
			selected_major=$(echo "$major_versions" | fzf --header "Major versiyon seçin (geri için '<<< Geri')" \
				--preview 'bash -c '"'"'
					if [ "$1" != "<<< Geri" ]; then
						major=$(echo "$1" | cut -d. -f1-2)
						echo "Alt versiyonlar:"
						echo "'"$all_versions"'" | grep -E -- "^${major}(\.|$)"
					else
						echo "Server type aşamasına geri dönmek için seçildi."
					fi
				'"'"' -- {}' \
				--preview-window=right:60%:wrap)

			# Eğer kullanıcı geri seçeneğini seçtiyse, farklı bir exit code veya özel değer döndürebilirsiniz:
			if [ -z "$selected_major" ]; then
				:
			elif [ "$selected_major" = "<<< Geri" ]; then
				# Örneğin, 2 koduyla geri dönüyoruz:
				return 2	
			else
				break
			fi
		done


		# Alt sürümleri listele
		versions=($(printf "%s\n" "${versions_array[@]}" | grep "^${selected_major%.*}"))

		# Geri tuşu ekleyerek listeyi düzenle
		versions="<<< Geri\n$versions"
		versions=$(echo -e "$versions" | sort -Vru | uniq)
		
		# Alt sürüm seçimi
		while true; do
			selected_version=$(printf "%s\n" "${versions[@]}" | sort -Vr | fzf --header "Alt versiyon seçin")
			if [[ "$selected_version" == "<<< Geri" ]]; then
				break
			else
				break
			fi
		done
		
		if [[ "$selected_version" == "<<< Geri" ]]; then
			:
		else
			break
		fi
	done
    echo "$selected_version"
}


# Server indirme fonksiyonu
download_server() {
    local server_type=$1
    local version=$2
    
    # URL'yi belirleyin
    if [[ "$server_type" == "Vanilla" ]]; then
        url="${VANILLA_VERSIONS[$version]}"
    elif [[ "$server_type" == "Forge" ]]; then
        url="${FORGE_VERSIONS[$version]}"
    elif [[ "$server_type" == "Paper" ]]; then
        url="${PAPER_VERSIONS[$version]}"
    elif [[ "$server_type" == "Fabric" ]]; then
        url="${FABRIC_VERSIONS[$version]}"
    elif [[ "$server_type" == "Sponge" ]]; then
        url="${SPONGE_VERSIONS[$version]}"
    fi
    
    # URL'nin boş olmadığını kontrol et
    if [[ -z "$url" ]]; then
        echo "Hata: $server_type için $version sürümü bulunamadı."
        exit 1
    fi
    
	download_dir="./${server_type}_${version}"  # Alt dizin yapısını oluşturuyoruz
    mkdir -p "$download_dir"  # Alt dizini oluştur (eğer yoksa)
    
    download_path="${download_dir}/server.jar" 

    
    # Dosyayı indir
    wget -O "$download_path" "$url" || { echo "İndirme başarısız!"; exit 1; }

    # İndirilen dosya yolunu döndür
    echo "$download_path"
}

# Java sürüm seçme fonksiyonu
select_java_version() {
    while true; do
        choice=$(printf "Java 8 (Minecraft 1.8 - 1.16.x)\nJava 17 (Minecraft 1.17 - 1.20.5)\nJava 21 (Minecraft 1.20.5+)\nÇıkış" | fzf --preview "echo Server Sürümü $selected_version")

        case "$choice" in
            "Java 8 (Minecraft 1.8 - 1.16.x)")
                echo "$JAVA_8"
                break
                ;;
            "Java 17 (Minecraft 1.17 - 1.20.5)")
                echo "$JAVA_17"
                break
                ;;
            "Java 21 (Minecraft 1.20.5+)")
                echo "$JAVA_21"
                break
                ;;
            "Çıkış"|"")
                echo ""
                exit 0
                ;;
            *)
                echo "Geçersiz seçim, tekrar deneyin."
                ;;
        esac
    done
}

select_ram() {
    local min_ram=$1  # minimum RAM parametresi alalım
    while true; do
        read -p "Maksimum RAM miktarını MB cinsinden girin (örneğin, 4096): " max_ram

        # Kullanıcı geçerli bir değer girerse
        if [[ "$max_ram" =~ ^[0-9]+$ ]] && [ "$max_ram" -ge "$min_ram" ]; then
            echo "$max_ram"
            break
        elif [[ "$max_ram" =~ ^[0-9]+$ ]] && [ "$max_ram" -lt "$min_ram" ]; then
            echo "Maksimum RAM, minimum RAM'den küçük olamaz! Lütfen tekrar deneyin."
        else
            echo "Geçersiz giriş. Lütfen bir sayı girin."
        fi
    done
}

# Ana işlem
server_file="$1"
update_server_properties() {
    local server_properties="$1"  # Fonksiyona dosya yolunu parametre olarak geçiyoruz

    # Eğer dosya bulunmazsa
    if [ -z "$server_properties" ]; then
        echo "server.properties dosyası bulunamadı. Lütfen dosyanın yolunu kontrol edin."
        return 1
    else
        # Dosyanın bulunduğu dizin ve adı
        echo "server.properties dosyası bulundu: $server_properties"

        # Dosyanın yedeğini alalım (isteğe bağlı)
        cp "$server_properties" "$server_properties.bak"

        # Max Oyuncu Sınırı
        read -p "Max Oyuncu Sınırı (current value: $(grep '^max-players' "$server_properties" | cut -d'=' -f2)): " max_players
        if [ -n "$max_players" ]; then
            sed -i "s/^max-players=.*/max-players=$max_players/" "$server_properties"
        fi

        # Gamemode
        read -p "Gamemode (creative, survival, adventure) (current value: $(grep '^gamemode' "$server_properties" | cut -d'=' -f2)): " gamemode
        if [ -n "$gamemode" ]; then
            sed -i "s/^gamemode=.*/gamemode=$gamemode/" "$server_properties"
        fi

        # Oyun Zorluğu
        read -p "Oyun Zorluğu (easy, normal, hard) (current value: $(grep '^difficulty' "$server_properties" | cut -d'=' -f2)): " difficulty
        if [ -n "$difficulty" ]; then
            sed -i "s/^difficulty=.*/difficulty=$difficulty/" "$server_properties"
        fi

        # Online Mode
        read -p "Online Mode (true, false) (current value: $(grep '^online-mode' "$server_properties" | cut -d'=' -f2)): " online_mode
        if [ -n "$online_mode" ]; then
            sed -i "s/^online-mode=.*/online-mode=$online_mode/" "$server_properties"
        fi

        # Enable Command Block
        read -p "Enable Command Block (true, false) (current value: $(grep '^enable-command-block' "$server_properties" | cut -d'=' -f2)): " enable_command_block
        if [ -n "$enable_command_block" ]; then
            sed -i "s/^enable-command-block=.*/enable-command-block=$enable_command_block/" "$server_properties"
        fi

        echo "server.properties dosyası güncellendi."
    fi
}
# Server type seçimi ve versiyon seçimi fonksiyonu
select_server_type() {
    while true; do
		server_type=$(printf "%s\n" "${!SERVER_URLS[@]}" | fzf --header "Server türü seçin")
		if [ -z "$server_type" ]; then
			:
		else
			break # Eğer server type seçilmediyse çık
		fi
	done
    
    # Sürüm seçimi
    selected_version=$(select_version "$server_type")
    status=$?

    if [ $status -eq 2 ]; then
        echo "Geri seçildi. Server type menüsüne dönülüyor..."
        # Geri dönülür, server type menüsü tekrar çağrılır
        select_server_type
    elif [ -z "$selected_version" ]; then
        exit 1  # Eğer versiyon seçilmediyse çık
    else
        echo "Seçilen versiyon: $selected_version"
    fi
}

if [[ -n "$server_file" ]]; then
    if [[ "$server_file" != *.jar ]]; then
        echo "Uyarı: $server_file bir .jar dosyası değil!"
        echo "Bir tuşa basarak çıkabilirsiniz..."
        read -n 1 -s  # Kullanıcıdan bir tuş girişi bekler
        exit 1
    fi

    if [[ ! -f "$server_file" ]]; then
        echo "Hata: $server_file diye bir dosya bulunamadı!"
        echo "Bir tuşa basarak çıkabilirsiniz..."
        read -n 1 -s  # Kullanıcıdan bir tuş girişi bekler
        exit 1
    fi
    
    echo "Java sürümünü seçin:"
    java_path=$(select_java_version)
    
    if [[ -z "$java_path" || ! -f "$java_path" ]]; then
        echo "Hata: Java sürümü seçilmedi veya bulunamadı!"
        exit 1
    fi
    min_ram="2048"
	max_ram=$(select_ram "$min_ram")
	[ -z "$max_ram" ] && exit 1
    echo "Server başlatılıyor: $server_file"
    "$java_path" -Xmx"${max_ram}M" -Xms"${min_ram}M" -jar "$server_file" nogui
    exit 0
fi

directories=("Forge_" "Vanilla_" "Fabric_" "Paper_" "Sponge_")

# Mevcut dizindeki klasörleri bulma
found_dirs=()
for dir in "${directories[@]}"; do
    # Bu klasör ile başlayan klasörleri kontrol et
    for folder in $(find . -maxdepth 1 -type d -name "$dir*"); do
        found_dirs+=("$folder")
    done
done

# Eğer bulunan klasörler varsa
found_dirs+=("Seçmeden devam et")

# Eğer bulunan klasörler varsa
if [ ${#found_dirs[@]} -gt 0 ]; then
    # fzf ile seçenek sunma (Kaçış karakterleri eklendi)
    while true; do
		selected_folder=$(printf "%s\n" "${found_dirs[@]}" | fzf --header="Dizinde server klasörleri bulunuyor. Onlarla devam etmek ister misiniz? (Server klasörü olup olmadığına dikkat edin ayrıca içindeki jar dosyasının adının server.jar olduğunu doğrulayın.)")

		# Eğer 'Seçmeden devam et' seçildiyse
		if [ "$selected_folder" == "Seçmeden devam et" ]; then
			select_server_type
			downloaded_file=$(download_server "$server_type" "$selected_version")
			server_directory=$(dirname "$downloaded_file")
			cd "$server_directory"
			break
		# Eğer bir klasör seçildiyse
		elif [ -n "$selected_folder" ]; then
			echo "Seçilen klasör: $selected_folder"
			# Seçilen klasöre cd komutu
			cd "$selected_folder"
			break
		fi
    done
else
	select_server_type
	downloaded_file=$(download_server "$server_type" "$selected_version")
	server_directory=$(dirname "$downloaded_file")
	cd "$server_directory"
fi


java_path=$(select_java_version)

if [[ -z "$java_path" || ! -f "$java_path" ]]; then
	echo "Hata: Java sürümü seçilmedi veya bulunamadı!"
	exit 1
fi
clear
min_ram="2048"
max_ram=$(select_ram "$min_ram")
[ -z "$max_ram" ] && exit 1

echo "Server türü: $server_type"
echo "Seçilen sürüm: $selected_version"
echo "İndirilen dosya: $downloaded_file"
echo "Java yolu: $java_path"
echo "Server başlatılıyor: $downloaded_file"

if [[ "$server_type" == "Forge" ]]; then
    eula_file="eula.txt"
    mv server.jar ForgeInstaller.jar
    if [[ -f "$eula_file" ]]; then
        echo "EULA dosyası bulundu, EULA'yı kabul ediyorum."
        sed -i 's/eula=false/eula=true/' "$eula_file"
        server_properties=$(find ./ -type f -name "server.properties" | head -n 1)

		# Eğer dosya bulunduysa fonksiyonu çağır
		if [ -n "$server_properties" ]; then
			clear
   			echo "Server Properties dosyasını düzenlemek ister misiniz"
			choice=$(printf "Duzenle\nİptal Et" | fzf --prompt="❓ Ne yapmak istersiniz? " --height=10 --border --reverse)
			if [[ "$choice" != "Duzenle" ]]; then
				update_server_properties "$server_properties"
			fi		
		else
			echo "server.properties dosyası bulunamadı."
		fi
    else
        echo "EULA dosyası bulunamadı, sunucuyu ilk kez başlatıyorum."
        # Sunucuyu başlat, EULA dosyası oluşturulsun
        "$java_path" -jar "ForgeInstaller.jar" --installServer
        # İlk çalıştırmadan sonra EULA'yı kabul et
        server_jar=$(find . -maxdepth 1 -type f -iname "*.jar" ! -name "ForgeInstaller.jar" | head -n 1)
        if [[ -n "$server_jar" ]]; then
			mv "$server_jar" "server.jar"
			"$java_path" -Xmx"${max_ram}M" -Xms"${min_ram}M" -jar "server.jar" nogui
		else
			echo "ForgeInstaller.jar duzgun kurulmamis"
		fi
        sed -i 's/eula=false/eula=true/' "$eula_file"
		server_properties=$(find ./ -type f -name "server.properties" | head -n 1)

		# Eğer dosya bulunduysa fonksiyonu çağır
		if [ -n "$server_properties" ]; then
			clear
   			echo "Server Properties dosyasını düzenlemek ister misiniz"
			choice=$(printf "Duzenle\nİptal Et" | fzf --prompt="❓ Ne yapmak istersiniz? " --height=10 --border --reverse)
			if [[ "$choice" == "Duzenle" ]]; then
				update_server_properties "$server_properties"
			fi	
		else
			echo "server.properties dosyası bulunamadı."
		fi
    fi
    
    # Sunucu kurulumu tamamlandığında sunucuyu başlat
    echo "Forge sunucusu başlatılıyor: $downloaded_file"
    server_jar=$(find . -maxdepth 1 -type f -iname "*.jar" ! -name "ForgeInstaller.jar" | head -n 1)

    if [[ -n "$server_jar" ]]; then
		mv "$server_jar" "server.jar"
        "$java_path" -Xmx"${max_ram}M" -Xms"${min_ram}M" -jar "server.jar" nogui
    else
        echo "server.jar dışındaki jar dosyası bulunamadı!"
    fi
    
    
else
	eula_file="eula.txt"  # Dosyanın bulunduğu dizinde eula.txt

	if [[ -f "$eula_file" ]]; then
		echo "EULA dosyası bulundu, EULA'yı kabul ediyorum."
		# EULA'yı true olarak güncelle
		sed -i 's/eula=false/eula=true/' "$eula_file"
		server_properties=$(find ./ -type f -name "server.properties" | head -n 1)

		# Eğer dosya bulunduysa fonksiyonu çağır
		if [ -n "$server_properties" ]; then
			clear
   			echo "Server Properties dosyasını düzenlemek ister misiniz"
			choice=$(printf "Duzenle\nİptal Et" | fzf --prompt="❓ Ne yapmak istersiniz? " --height=10 --border --reverse)
			if [[ "$choice" == "Duzenle" ]]; then
				update_server_properties "$server_properties"
			fi	
		else
			echo "server.properties dosyası bulunamadı."
		fi
	else
		echo "EULA dosyası bulunamadı, sunucuyu ilk kez başlatıyorum."
		# Sunucuyu başlat, EULA dosyası oluşturulsun
		"$java_path" -Xmx"${max_ram}M" -Xms"${min_ram}M" -jar "server.jar" nogui
		server_properties=$(find ./ -type f -name "server.properties" | head -n 1)

		# Eğer dosya bulunduysa fonksiyonu çağır
		if [ -n "$server_properties" ]; then
			clear
   			echo "Server Properties dosyasını düzenlemek ister misiniz"
			choice=$(printf "Duzenle\nİptal Et" | fzf --prompt="❓ Ne yapmak istersiniz? " --height=10 --border --reverse)
			if [[ "$choice" == "Duzenle" ]]; then
				update_server_properties "$server_properties"
			fi	
		else
			echo "server.properties dosyası bulunamadı."
		fi

		# İlk çalıştırmadan sonra EULA'yı kabul et
		sed -i 's/eula=false/eula=true/' "$eula_file"
	fi

	# EULA'yı kabul ettikten sonra sunucuyu başlat
	echo "Sunucu başlatılıyor: $downloaded_file"
	"$java_path" -Xmx"${max_ram}M" -Xms"${min_ram}M" -jar "server.jar" nogui
fi

