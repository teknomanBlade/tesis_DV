using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class BaseballLauncherDestroyAnim : MonoBehaviour
{
    //[SerializeField]
    //private GameObject particles;
    public ParticleSystem explosionParticle;
    [SerializeField]
    private Animator _anim;
    //private bool IsDestroyed
    public delegate void OnDestroyedDelegate(bool destroyed);
    public event OnDestroyedDelegate OnDestroyed;
    [SerializeField]
    private bool _isDestroyed;
    public bool IsDestroyed
    {
        get { return _isDestroyed; }
        set
        {
            if (_isDestroyed == value) return;
            _isDestroyed = value;
            OnDestroyed?.Invoke(_isDestroyed);
        }
    }
    void Awake()
    {
        _anim = GetComponent<Animator>();
        StartCoroutine(DestroyThisTrapAnim("Destroyed"));
        //Instantiate(particles, transform.position, transform.rotation);
    }
    public void ActiveExplosionEffect()
    {
        explosionParticle.gameObject.SetActive(!explosionParticle.gameObject.activeSelf);
        explosionParticle.transform.SetParent(null, true);
        explosionParticle.Play();
    }
    IEnumerator DestroyThisTrapAnim(string name)
    {
        _anim.SetBool("IsDestroyed", true);
        GameVars.Values.soundManager.PlaySoundAtPoint("TurretDestroyed", transform.position, 0.6f);
        var clips = _anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        _anim.SetBool("IsDestroyed", false);
        DestroyTrap();
    }

    public void DestroyTrap()
    {
        IsDestroyed = true;
        Destroy(this.gameObject);
    }
}
