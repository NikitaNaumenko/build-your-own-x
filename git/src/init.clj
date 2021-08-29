(ns init
  (:require [clojure.java.io :as io]
            [clojure.string :as string]))

(defn init [path]
  (let [filepath (string/join "/" [path ".git"])]
    (.mkdir (io/file filepath))))

(defn -main
  ([] (init "."))
  ([path] (init path)))

(comment
  (init "/tmp")
  (-main "/tmp"))

