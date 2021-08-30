(ns cljit.init-test
  (:require [cljit.init :as init]
            [clojure.test :refer :all]
            [clojure.java.io :as io]))

(def cljit-dir-path "/tmp/.cljit")

(defn delete-file-recursively [f]
  (let [f (io/file f)]
    (when (.exists f)
    (if (.isDirectory f)
      (doseq [child (.listFiles f)]
        (delete-file-recursively child)))
    (io/delete-file f))))

(use-fixtures :each
              (fn [f]
                (delete-file-recursively cljit-dir-path)
                (f)
                (delete-file-recursively cljit-dir-path)))

(deftest create-dir
  (init/-main "/tmp")

  (let [dir (io/file "/tmp/.cljit")
        head (io/file "/tmp/.cljit/HEAD")]
    (is (.isDirectory dir))
    (is (.exists head))
    (is (.isDirectory (io/file "/tmp/.cljit/objects/info")))
    (is (.isDirectory (io/file "/tmp/.cljit/objects/pack")))
    (is (.isDirectory (io/file "/tmp/.cljit/refs/head")))
    (is (.isDirectory (io/file "/tmp/.cljit/refs/tags")))))

(deftest when-dir-already-exists
  (init/-main "/tmp")
  (is (thrown? Exception (init/-main "/tmp"))))

(run-tests)
