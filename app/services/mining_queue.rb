class MiningQueue
  # Trabajos de minado pendientes (encolados o en ejecución).
  # Devuelve 0 si el adaptador no es Solid Queue (tests) o la BD de cola no responde.
  def self.pending
    return 0 unless ActiveJob::Base.queue_adapter_name.to_s == "solid_queue"

    SolidQueue::Job.where(class_name: "MineBlockJob", finished_at: nil).count
  rescue ActiveRecord::ActiveRecordError
    0
  end
end
