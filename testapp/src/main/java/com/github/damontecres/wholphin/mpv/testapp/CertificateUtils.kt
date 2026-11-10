package com.github.damontecres.wholphin.mpv.testapp

import java.io.File
import java.io.FileOutputStream
import java.security.KeyStore
import java.security.cert.X509Certificate
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.X509TrustManager
import kotlin.io.encoding.Base64

/**
 * Utility functions to get the trusted system certificates
 */
object CertificateUtils {
    /**
     * Get the system trusted [X509Certificate]
     */
    fun getSystemCerts(): List<X509Certificate> {
        val tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm())
        // Null gets system
        tmf.init(null as KeyStore?)
        val certs =
            tmf.trustManagers
                .filterIsInstance<X509TrustManager>()
                .flatMap { it.acceptedIssuers.toList() }
        return certs
    }

    /**
     * Copy the trusted system certs to the specified file such as `File(context.filesDir, "certs.pem")`
     *
     */
    fun copySystemCerts(file: File) {
        val certs = getSystemCerts().map { it.convertToPem() }

        FileOutputStream(file).bufferedWriter().use { fos ->
            certs.forEach {
                fos.write(it)
                fos.write("\n\n")
            }
        }
    }

    /**
     * Convert the [X509Certificate] into its plaintext PEM encoding
     */
    fun X509Certificate.convertToPem(): String {
        val base64Cert = Base64.Pem.encode(this.encoded)
        return "# ${issuerX500Principal.name}\n-----BEGIN CERTIFICATE-----\n$base64Cert\n-----END CERTIFICATE-----"
    }
}
