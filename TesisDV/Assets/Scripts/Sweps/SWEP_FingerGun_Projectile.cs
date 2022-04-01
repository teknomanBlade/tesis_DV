using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SWEP_FingerGun_Projectile : MonoBehaviour
{
    private void Start()
    {
        Destroy(gameObject, 3f);
    }

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Hello");
        if (collision.gameObject.layer == 12)
        {
            Debug.Log("Die");
            collision.gameObject.GetComponent<EnemyBase>().Die();
            Destroy(gameObject);
        }
    }
}
