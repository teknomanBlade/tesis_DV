using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayAttackRing : MonoBehaviour
{
    public Enemy _myOwner;
    public int _damageAmount;

    private void Awake()
    {
        _myOwner = transform.GetComponentInParent<Enemy>();
    }

    public void EnableBoxCollider()
    {
        Invoke("ActiveCollider", 0.8f);
    }

    public void ActiveCollider()
    {
        GetComponent<BoxCollider>().enabled = true;
    }

    void OnTriggerEnter(Collider other)
    {
        var player = other.GetComponent<Player>();

        if (player)
        {
            //Debug.Log("ENTRA EN TRIGGER DAMAGE?");
            other.GetComponent<Player>().Damage(_damageAmount, _myOwner.enemyType);
            GetComponent<BoxCollider>().enabled = false;
        }
    }
}
