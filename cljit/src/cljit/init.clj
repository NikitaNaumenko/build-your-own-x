(ns cljit.init
  (:require [clojure.java.io :as io]
            [clojure.string :as string]))

(def cljit-directory ".cljit")
(def cljit-objects-directory (string/join "/" [cljit-directory "objects"]))
(def cljit-refs-directory (string/join "/" [cljit-directory "refs"]))

; (.mkdir (io/file "jj"))
; (.isDirectory (io/file "jj"))

(defn init [path]
  (let [init-path (string/join "/" [path cljit-directory])
        init-obj (io/file init-path)]
    (if (.exists init-obj)
      (throw (Exception. ".cljit is already exists"))
      (.mkdir init-obj))))

(defn -main
  ([] (init "."))
  ([path] (init path)))

(comment
  (-main)
  (init "/tmp")
  (-main "/tmp"))

