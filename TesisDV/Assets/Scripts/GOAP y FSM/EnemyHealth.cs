using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHealth : MonoBehaviour, IHittableObserver
{
    public int hp = 5;

    public void TakeDamage()
    {
        hp--;
        if (hp <= 0) Die();
    }

    public void OnNotify(string message)
    {
        if (message.Equals("RacketHit"))
        {
            
            
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            TakeDamage();

            
        }
    }

    private void Die()
    {
        Destroy(this.gameObject);
    }

    
}
