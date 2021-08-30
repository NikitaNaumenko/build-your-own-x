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
      (do
        (.mkdir init-obj)
        (let [ objects-info (io/file (string/join "/" [path cljit-objects-directory "info"]))
              objects-pack (io/file (string/join "/" [path cljit-objects-directory "pack"]))
              refs-head (io/file (string/join "/" [path cljit-refs-directory "head"]))
              refs-tags (io/file (string/join "/" [path cljit-refs-directory "tags"]))]
           (run! #(io/make-parents %) [objects-info objects-pack refs-head refs-tags])
           (run! #(.mkdir %) [objects-info objects-pack refs-head refs-tags])
           (with-open [writer (io/writer (string/join  "/" [init-path "HEAD"]) :append true)]
             (.write writer (str "ref: refs/heads/master"))))))))

; (.mkdir (io/file (string/join "/" ["/tmp" cljit-objects-directory "info"])))
; (with-open [w (io/writer  "i.txt" :append true)]
;     (.write w (str "hello" "world")))
(defn -main
  ([] (init "."))
  ([path] (init path)))

(comment
  (-main)
  (init "/tmp")
  (-main "/tmp"))

