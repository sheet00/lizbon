# 失敗したジョブをキュー削除管理
Delayed::Worker.destroy_failed_jobs = false
# リトライ実行
Delayed::Worker.max_attempts = 0
# delayjob log
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'job.log'))
