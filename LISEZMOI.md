# Mkkly Nails : mettre le site en ligne

Compte environ 15 minutes, une seule fois. Tout est gratuit.

## 1. Créer la base de données (Supabase)

1. Va sur supabase.com et crée un compte, puis **New project** (région : Paris / West EU). Garde le mot de passe de la base quelque part.
2. Ouvre **SQL Editor > New query**, colle tout le contenu de `supabase.sql`.
3. Dans ce texte, remplace `TON_EMAIL_ICI` par l'e-mail de ton espace pro, puis clique sur **Run**.
4. **Authentication > Users > Add user > Create new user** : mets ce même e-mail et un mot de passe. Coche « Auto confirm user ».
5. **Authentication > Sign In / Providers** : désactive **Allow new users to sign up** (personne d'autre ne peut créer de compte).
6. **Project Settings > API** : copie la **Project URL** et la clé **anon public**.

## 2. Brancher le site

Ouvre `index.html`, tout en haut du script, et colle :

```js
SUPABASE_URL: "https://xxxx.supabase.co",
SUPABASE_ANON_KEY: "eyJ...",
```

La clé « anon public » peut être visible sur le site : les règles de la base empêchent les clientes de voir les rendez-vous des autres.

## 3. Mettre en ligne (GitHub Pages)

1. Sur GitHub, crée un dépôt public `mkkly-nails`.
2. Envoie-y tous les fichiers de ce dossier (sauf `supabase.sql` et ce fichier, pas obligatoires).
3. **Settings > Pages > Deploy from a branch > main / (root)**.
4. Ton site sera à l'adresse `https://sadoucflex.github.io/mkkly-nails/`.

## 4. Au quotidien

- **Lien à mettre dans ta bio Insta** : `https://sadoucflex.github.io/mkkly-nails/#reserver` (ouvre directement la réservation).
- **Ton espace pro** : `https://sadoucflex.github.io/mkkly-nails/#admin`. Sur iPhone : Safari > Partager > « Sur l'écran d'accueil » pour l'avoir comme une appli.
- **Disponibilités** : choisis un jour, coche les heures, la durée, et « Répéter » pour les semaines suivantes.
- **Rendez-vous** : « Elle a confirmé » quand la cliente confirme la veille. « Annuler le rdv » libère le créneau.
- **Photos** : ajoute tes poses depuis ta galerie, elles apparaissent dans « Mes poses ».
- **Tarifs** : modifie le bloc `TARIFS` en haut du script de `index.html`, les prix changent partout.
