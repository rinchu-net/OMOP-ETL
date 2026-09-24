#!/bin/bash

# Atlas+WebAPI+RStudio用docker-compose（引数対応）
# このスクリプトを実行可能にする: chmod +x docker-compose-ohdsi.sh

# スクリプトの場所に移動
cd "$(dirname "$0")"

# 環境変数 DOCKER_BUILDKIT を有効化
export DOCKER_BUILDKIT=1

# 実行するコマンドを表示
set -x

if [ $# -eq 0 ]; then
	docker-compose -f docker-compose-build.yml up -d
else
	docker-compose -f docker-compose-build.yml "$@"
fi

# コマンド表示を終了
set +x

echo ""
echo "サービスの状態確認: docker-compose -f docker-compose-build.yml ps"
echo "停止する場合:        docker-compose -f docker-compose-build.yml down"
echo ""
